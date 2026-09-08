using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.EventBus.Local;

namespace LaundrySaaS.Orders.Orders;

public class OrderAppService : OrdersAppService, IOrderAppService
{
    private readonly IRepository<Order, Guid> _orderRepository;
    private readonly ILocalEventBus _localEventBus;

    public OrderAppService(
        IRepository<Order, Guid> orderRepository,
        ILocalEventBus localEventBus)
    {
        _orderRepository = orderRepository;
        _localEventBus = localEventBus;
    }

    public async Task<OrderDto> CreateAsync(CreateOrderDto input)
    {
        Check.NotNull(input, nameof(input));
        if (input.LaundryId == Guid.Empty)
        {
            throw new UserFriendlyException("معرّف المغسلة مطلوب لإنشاء الفاتورة");
        }
        if (string.IsNullOrWhiteSpace(input.CustomerName))
        {
            throw new UserFriendlyException("اسم العميل مطلوب لإصدار الفاتورة");
        }
        if (input.Items == null || input.Items.Count == 0)
        {
            throw new UserFriendlyException("يجب اختيار خدمة واحدة على الأقل في الفاتورة");
        }

        var orderId = GuidGenerator.Create();
        var orderNumber = GenerateOrderNumber();

        var order = new Order(
            orderId,
            input.LaundryId,
            orderNumber,
            input.CustomerName.Trim(),
            input.IsWalkIn,
            input.CustomerId,
            input.CustomerPhoneNumber?.Trim(),
            input.DeliveryType,
            null,
            null,
            OrderStatus.Pending,
            input.PaymentStatus,
            input.PaymentMethod,
            input.DiscountAmount,
            input.TaxAmount,
            input.PaidAmount,
            input.Notes?.Trim(),
            CurrentTenant.Id
        );

        foreach (var item in input.Items)
        {
            order.AddItem(
                item.ServiceItemId,
                item.ItemName.Trim(),
                item.UnitPrice,
                item.Quantity <= 0 ? 1 : item.Quantity,
                item.Notes
            );
        }

        order.RecalculateTotals();

        decimal initialPaid = input.PaymentStatus switch
        {
            PaymentStatus.Paid => (input.PaidAmount > 0 ? input.PaidAmount : order.TotalAmount),
            PaymentStatus.PartiallyPaid => input.PaidAmount,
            _ => (input.PaidAmount > 0 ? input.PaidAmount : 0)
        };
        order.SetInitialPayment(initialPaid, input.PaymentMethod);

        await _orderRepository.InsertAsync(order, autoSave: true);

        await _localEventBus.PublishAsync(new OrderCreatedEto
        {
            OrderId = order.Id,
            TenantId = order.TenantId,
            LaundryId = order.LaundryId,
            OrderNumber = order.OrderNumber,
            CustomerId = order.CustomerId,
            CustomerName = order.CustomerName,
            TotalAmount = order.TotalAmount,
            PaidAmount = order.PaidAmount,
            RemainingAmount = order.RemainingAmount,
            TaxAmount = order.TaxAmount,
            PaymentStatus = order.PaymentStatus,
            PaymentMethod = order.PaymentMethod,
            CreationTime = order.CreationTime
        });

        return MapToDto(order);
    }

    public async Task<OrderDto> GetAsync(Guid id)
    {
        var queryable = await _orderRepository.WithDetailsAsync(o => o.Items);
        var order = await AsyncExecuter.FirstOrDefaultAsync(queryable.Where(o => o.Id == id));
        if (order == null)
        {
            throw new UserFriendlyException("الطلب أو الفاتورة غير موجودة");
        }

        return MapToDto(order);
    }

    public async Task<PagedResultDto<OrderDto>> GetListAsync(GetOrdersInputDto input)
    {
        var queryable = await _orderRepository.WithDetailsAsync(o => o.Items);

        if (input.LaundryId.HasValue && input.LaundryId.Value != Guid.Empty)
        {
            queryable = queryable.Where(o => o.LaundryId == input.LaundryId.Value);
        }

        if (input.Status.HasValue)
        {
            queryable = queryable.Where(o => o.Status == input.Status.Value);
        }

        if (input.PaymentStatus.HasValue)
        {
            queryable = queryable.Where(o => o.PaymentStatus == input.PaymentStatus.Value);
        }

        if (input.IsWalkIn.HasValue)
        {
            queryable = queryable.Where(o => o.IsWalkIn == input.IsWalkIn.Value);
        }

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            var filter = input.Filter.Trim();
            queryable = queryable.Where(o =>
                o.OrderNumber.Contains(filter) ||
                o.CustomerName.Contains(filter) ||
                (o.CustomerPhoneNumber != null && o.CustomerPhoneNumber.Contains(filter)));
        }

        var totalCount = await AsyncExecuter.CountAsync(queryable);

        var pagedQuery = queryable
            .OrderByDescending(o => o.CreationTime)
            .Skip(input.SkipCount)
            .Take(input.MaxResultCount);

        var orders = await AsyncExecuter.ToListAsync(pagedQuery);

        return new PagedResultDto<OrderDto>(
            totalCount,
            orders.Select(MapToDto).ToList()
        );
    }

    public async Task<OrderDto> UpdateStatusAsync(Guid id, OrderStatus status)
    {
        var queryable = await _orderRepository.WithDetailsAsync(o => o.Items);
        var order = await AsyncExecuter.FirstOrDefaultAsync(queryable.Where(o => o.Id == id));
        if (order == null)
        {
            throw new UserFriendlyException("الطلب أو الفاتورة غير موجودة");
        }

        order.SetStatus(status);
        await _orderRepository.UpdateAsync(order, autoSave: true);

        return MapToDto(order);
    }

    public async Task<OrderDto> RecordPaymentAsync(Guid id, RecordOrderPaymentDto input)
    {
        Check.NotNull(input, nameof(input));
        var queryable = await _orderRepository.WithDetailsAsync(o => o.Items);
        var order = await AsyncExecuter.FirstOrDefaultAsync(queryable.Where(o => o.Id == id));
        if (order == null)
        {
            throw new UserFriendlyException("الطلب أو الفاتورة غير موجودة");
        }

        order.RecordPayment(input.Amount, input.PaymentMethod);

        if (input.MarkAsDelivered)
        {
            if (order.RemainingAmount > 0)
            {
                throw new UserFriendlyException($"لا يمكن تسليم الفاتورة لأن هناك متبقي قدره {order.RemainingAmount} ر.س لم يُسدد.");
            }
            order.SetStatus(OrderStatus.Delivered);
        }

        await _orderRepository.UpdateAsync(order, autoSave: true);

        await _localEventBus.PublishAsync(new OrderPaymentRecordedEto
        {
            OrderId = order.Id,
            TenantId = order.TenantId,
            LaundryId = order.LaundryId,
            OrderNumber = order.OrderNumber,
            CustomerId = order.CustomerId,
            CustomerName = order.CustomerName,
            Amount = input.Amount,
            RemainingAmount = order.RemainingAmount,
            PaymentMethod = input.PaymentMethod,
            IsDeliverySettlement = input.MarkAsDelivered || order.Status == OrderStatus.Delivered,
            PaymentDate = Clock.Now
        });

        return MapToDto(order);
    }

    public async Task<LaundryReportDto> GetReportAsync(GetLaundryReportInputDto input)
    {
        Check.NotNull(input, nameof(input));
        if (input.LaundryId == Guid.Empty)
        {
            throw new UserFriendlyException("معرّف المغسلة مطلوب لعرض التقارير");
        }

        var queryable = await _orderRepository.WithDetailsAsync(o => o.Items);
        queryable = queryable.Where(o => o.LaundryId == input.LaundryId);

        if (input.StartDate.HasValue)
        {
            var startUtc = DateTime.SpecifyKind(input.StartDate.Value.Date, DateTimeKind.Utc);
            queryable = queryable.Where(o => o.CreationTime >= startUtc);
        }

        if (input.EndDate.HasValue)
        {
            var endUtc = DateTime.SpecifyKind(input.EndDate.Value.Date.AddDays(1).AddTicks(-1), DateTimeKind.Utc);
            queryable = queryable.Where(o => o.CreationTime <= endUtc);
        }

        var orders = await AsyncExecuter.ToListAsync(queryable);

        var report = new LaundryReportDto();

        // 1. Summary
        report.Summary.TotalOrdersCount = orders.Count;
        report.Summary.TotalItemsCount = orders.SelectMany(o => o.Items ?? Enumerable.Empty<OrderItem>()).Sum(i => i.Quantity);
        report.Summary.TotalSales = orders.Where(o => o.Status != OrderStatus.Cancelled).Sum(o => o.TotalAmount);
        report.Summary.TotalPaid = orders.Where(o => o.Status != OrderStatus.Cancelled).Sum(o => o.PaidAmount);
        report.Summary.TotalRemaining = orders.Where(o => o.Status != OrderStatus.Cancelled).Sum(o => o.RemainingAmount);
        report.Summary.TotalDiscount = orders.Where(o => o.Status != OrderStatus.Cancelled).Sum(o => o.DiscountAmount);
        report.Summary.TotalTax = orders.Where(o => o.Status != OrderStatus.Cancelled).Sum(o => o.TaxAmount);

        // 2. Payment Breakdown
        var activeOrders = orders.Where(o => o.Status != OrderStatus.Cancelled).ToList();
        report.PaymentBreakdown.CashAmount = activeOrders.Where(o => o.PaymentMethod == PaymentMethod.Cash).Sum(o => o.PaidAmount);
        report.PaymentBreakdown.CardAmount = activeOrders.Where(o => o.PaymentMethod == PaymentMethod.Card).Sum(o => o.PaidAmount);
        report.PaymentBreakdown.TransferAmount = activeOrders.Where(o => o.PaymentMethod == PaymentMethod.Transfer).Sum(o => o.PaidAmount);
        report.PaymentBreakdown.LaterAmount = activeOrders.Sum(o => o.RemainingAmount);

        // 3. Status Breakdown
        report.StatusBreakdown.PendingCount = orders.Count(o => o.Status == OrderStatus.Pending || o.Status == OrderStatus.Confirmed);
        report.StatusBreakdown.ProcessingCount = orders.Count(o => o.Status == OrderStatus.Processing || o.Status == OrderStatus.PickedUp);
        report.StatusBreakdown.ReadyCount = orders.Count(o => o.Status == OrderStatus.OutForDelivery);
        report.StatusBreakdown.DeliveredCount = orders.Count(o => o.Status == OrderStatus.Delivered);
        report.StatusBreakdown.CancelledCount = orders.Count(o => o.Status == OrderStatus.Cancelled);

        // 4. Top Services
        var allItems = activeOrders.SelectMany(o => o.Items ?? Enumerable.Empty<OrderItem>()).ToList();
        var totalServiceSales = allItems.Sum(i => i.TotalPrice);

        report.TopServices = allItems
            .GroupBy(i => i.ItemName)
            .Select(g => new TopServiceItemDto
            {
                ServiceName = g.Key,
                Quantity = g.Sum(x => x.Quantity),
                TotalAmount = g.Sum(x => x.TotalPrice),
                Percentage = totalServiceSales > 0
                    ? Math.Round((double)(g.Sum(x => x.TotalPrice) / totalServiceSales * 100), 1)
                    : 0.0
            })
            .OrderByDescending(s => s.TotalAmount)
            .Take(10)
            .ToList();

        // 5. Outstanding Debts
        var now = DateTime.UtcNow;
        report.OutstandingDebts = activeOrders
            .Where(o => o.RemainingAmount > 0)
            .OrderByDescending(o => o.RemainingAmount)
            .Take(50)
            .Select(o => new OutstandingDebtDto
            {
                OrderId = o.Id,
                OrderNumber = o.OrderNumber,
                CustomerName = o.CustomerName,
                CustomerPhoneNumber = o.CustomerPhoneNumber,
                TotalAmount = o.TotalAmount,
                PaidAmount = o.PaidAmount,
                RemainingAmount = o.RemainingAmount,
                CreationTime = o.CreationTime,
                DaysPending = Math.Max(0, (now - o.CreationTime).Days)
            })
            .ToList();

        return report;
    }

    private string GenerateOrderNumber()
    {
        var datePart = DateTime.UtcNow.ToString("yyMMdd");
        var randomPart = Random.Shared.Next(1000, 9999);
        return $"INV-{datePart}-{randomPart}";
    }

    private OrderDto MapToDto(Order order)
    {
        return new OrderDto
        {
            Id = order.Id,
            TenantId = order.TenantId,
            LaundryId = order.LaundryId,
            OrderNumber = order.OrderNumber,
            IsWalkIn = order.IsWalkIn,
            CustomerId = order.CustomerId,
            CustomerName = order.CustomerName,
            CustomerPhoneNumber = order.CustomerPhoneNumber,
            DeliveryType = order.DeliveryType,
            DriverId = order.DriverId,
            Status = order.Status,
            PaymentStatus = order.PaymentStatus,
            PaymentMethod = order.PaymentMethod,
            Subtotal = order.Subtotal,
            DiscountAmount = order.DiscountAmount,
            TaxAmount = order.TaxAmount,
            TotalAmount = order.TotalAmount,
            PaidAmount = order.PaidAmount,
            RemainingAmount = order.RemainingAmount,
            Notes = order.Notes,
            CreationTime = order.CreationTime,
            Items = order.Items?.Select(i => new OrderItemDto
            {
                Id = i.Id,
                OrderId = i.OrderId,
                ServiceItemId = i.ServiceItemId,
                ItemName = i.ItemName,
                UnitPrice = i.UnitPrice,
                Quantity = i.Quantity,
                TotalPrice = i.TotalPrice,
                Notes = i.Notes
            }).ToList() ?? new List<OrderItemDto>()
        };
    }
}
