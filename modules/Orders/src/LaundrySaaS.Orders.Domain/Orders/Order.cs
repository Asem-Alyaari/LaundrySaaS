using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using LaundrySaaS.ValueObjects;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Orders.Orders;

public class Order : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public Guid LaundryId { get; private set; }
    public string OrderNumber { get; private set; }
    public bool IsWalkIn { get; private set; }
    public Guid? CustomerId { get; private set; }
    public string CustomerName { get; private set; }
    public string? CustomerPhoneNumber { get; private set; }
    public OrderDeliveryType DeliveryType { get; private set; }
    public Guid? DriverId { get; private set; }
    public Address? DeliveryAddress { get; private set; }
    public OrderStatus Status { get; private set; }
    public PaymentStatus PaymentStatus { get; private set; }
    public PaymentMethod PaymentMethod { get; private set; }
    public decimal Subtotal { get; private set; }
    public decimal DiscountAmount { get; private set; }
    public decimal TaxAmount { get; private set; }
    public decimal TotalAmount { get; private set; }
    public decimal PaidAmount { get; private set; }
    public decimal RemainingAmount { get; private set; }
    public string? Notes { get; private set; }

    public virtual ICollection<OrderItem> Items { get; private set; }

    private Order()
    {
        OrderNumber = string.Empty;
        CustomerName = string.Empty;
        Items = new Collection<OrderItem>();
    }

    public Order(
        Guid id,
        Guid laundryId,
        string orderNumber,
        string customerName,
        bool isWalkIn = true,
        Guid? customerId = null,
        string? customerPhoneNumber = null,
        OrderDeliveryType deliveryType = OrderDeliveryType.InStore,
        Address? deliveryAddress = null,
        Guid? driverId = null,
        OrderStatus status = OrderStatus.Pending,
        PaymentStatus paymentStatus = PaymentStatus.Unpaid,
        PaymentMethod paymentMethod = PaymentMethod.Cash,
        decimal discountAmount = 0,
        decimal taxAmount = 0,
        decimal paidAmount = 0,
        string? notes = null,
        Guid? tenantId = null)
        : base(id)
    {
        LaundryId = laundryId;
        OrderNumber = orderNumber;
        CustomerName = customerName;
        IsWalkIn = isWalkIn;
        CustomerId = customerId;
        CustomerPhoneNumber = customerPhoneNumber;
        DeliveryType = deliveryType;
        DeliveryAddress = deliveryAddress;
        DriverId = driverId;
        Status = status;
        PaymentStatus = paymentStatus;
        PaymentMethod = paymentMethod;
        DiscountAmount = discountAmount;
        TaxAmount = taxAmount;
        PaidAmount = paidAmount;
        RemainingAmount = Math.Max(0, TotalAmount - PaidAmount);
        Notes = notes;
        TenantId = tenantId;
        Items = new Collection<OrderItem>();
    }

    public void AddItem(
        Guid serviceItemId,
        string itemName,
        decimal unitPrice,
        int quantity,
        string? notes = null)
    {
        var existing = Items.FirstOrDefault(i => i.ServiceItemId == serviceItemId);
        if (existing != null)
        {
            existing.UpdateQuantity(existing.Quantity + quantity);
            if (!string.IsNullOrWhiteSpace(notes))
            {
                existing.SetNotes(notes);
            }
        }
        else
        {
            var item = new OrderItem(
                Guid.NewGuid(),
                Id,
                serviceItemId,
                itemName,
                unitPrice,
                quantity,
                notes);
            Items.Add(item);
        }

        RecalculateTotals();
    }

    public void RecalculateTotals()
    {
        Subtotal = Items.Sum(i => i.TotalPrice);
        TotalAmount = Math.Max(0, Subtotal - DiscountAmount + TaxAmount);
        RemainingAmount = Math.Max(0, TotalAmount - PaidAmount);

        if (TotalAmount > 0 && PaidAmount >= TotalAmount)
        {
            PaymentStatus = PaymentStatus.Paid;
            RemainingAmount = 0;
        }
        else if (PaidAmount > 0)
        {
            PaymentStatus = PaymentStatus.PartiallyPaid;
        }
        else
        {
            PaymentStatus = PaymentStatus.Unpaid;
        }
    }

    public void UpdateFinancials(decimal discountAmount, decimal taxAmount)
    {
        DiscountAmount = discountAmount;
        TaxAmount = taxAmount;
        RecalculateTotals();
    }

    public void SetInitialPayment(decimal paidAmount, PaymentMethod paymentMethod)
    {
        PaidAmount = Math.Max(0, paidAmount);
        PaymentMethod = paymentMethod;
        RemainingAmount = Math.Max(0, TotalAmount - PaidAmount);

        if (TotalAmount > 0 && PaidAmount >= TotalAmount)
        {
            PaymentStatus = PaymentStatus.Paid;
            RemainingAmount = 0;
        }
        else if (PaidAmount > 0)
        {
            PaymentStatus = PaymentStatus.PartiallyPaid;
        }
        else
        {
            PaymentStatus = PaymentStatus.Unpaid;
        }
    }

    public void RecordPayment(decimal amount, PaymentMethod method)
    {
        if (Status == OrderStatus.Delivered)
        {
            throw new BusinessException("Orders:DeliveredOrderLocked", "لا يمكن تسجيل دفعات أو تعديل فاتورة تم تسليمها ومقفلة.");
        }

        if (amount <= 0)
        {
            throw new BusinessException("Orders:InvalidPaymentAmount", "مبلغ الدفع يجب أن يكون أكبر من صفر.");
        }

        PaidAmount += amount;
        RemainingAmount = Math.Max(0, TotalAmount - PaidAmount);
        PaymentMethod = method;

        if (RemainingAmount == 0)
        {
            PaymentStatus = PaymentStatus.Paid;
        }
        else
        {
            PaymentStatus = PaymentStatus.PartiallyPaid;
        }
    }

    public void SetStatus(OrderStatus newStatus)
    {
        if (Status == OrderStatus.Delivered && newStatus != OrderStatus.Delivered)
        {
            throw new BusinessException("Orders:DeliveredOrderLocked", "لا يمكن تعديل حالة الفاتورة بعد تسليمها نهائياً.");
        }

        if (newStatus == OrderStatus.Delivered && RemainingAmount > 0)
        {
            throw new BusinessException("Orders:CannotDeliverUnpaidOrder", "لا يمكن تسليم الفاتورة إلا بعد سداد كامل المبلغ المتبقي.");
        }

        Status = newStatus;
    }

    public void SetPaymentStatus(PaymentStatus paymentStatus, PaymentMethod? method = null)
    {
        PaymentStatus = paymentStatus;
        if (method.HasValue)
        {
            PaymentMethod = method.Value;
        }
    }

    public void AssignDriver(Guid driverId)
    {
        DriverId = driverId;
    }
}
