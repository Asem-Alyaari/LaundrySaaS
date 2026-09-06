using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Orders.Orders;

public class OrderDto : FullAuditedEntityDto<Guid>
{
    public Guid? TenantId { get; set; }
    public Guid LaundryId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public bool IsWalkIn { get; set; }
    public Guid? CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string? CustomerPhoneNumber { get; set; }
    public OrderDeliveryType DeliveryType { get; set; }
    public Guid? DriverId { get; set; }
    public OrderStatus Status { get; set; }
    public PaymentStatus PaymentStatus { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public decimal Subtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string? Notes { get; set; }

    public List<OrderItemDto> Items { get; set; } = new();
}
