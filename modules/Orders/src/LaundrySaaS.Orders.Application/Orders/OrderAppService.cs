using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Orders.Orders;

public class OrderAppService : OrdersAppService, IOrderAppService
{
    private readonly IRepository<Order, Guid> _orderRepository;

    public OrderAppService(IRepository<Order, Guid> orderRepository)
    {
        _orderRepository = orderRepository;
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

        await _orderRepository.InsertAsync(order, autoSave: true);

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
