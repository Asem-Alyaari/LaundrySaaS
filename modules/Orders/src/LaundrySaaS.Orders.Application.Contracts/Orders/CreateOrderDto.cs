using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Orders.Orders;

public class CreateOrderDto
{
    [Required]
    public Guid LaundryId { get; set; }

    public bool IsWalkIn { get; set; } = true;

    public Guid? CustomerId { get; set; }

    [Required]
    [MaxLength(128)]
    public string CustomerName { get; set; } = string.Empty;

    [MaxLength(32)]
    public string? CustomerPhoneNumber { get; set; }

    public OrderDeliveryType DeliveryType { get; set; } = OrderDeliveryType.InStore;

    public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.Unpaid;

    public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.Cash;

    public decimal DiscountAmount { get; set; } = 0;

    public decimal TaxAmount { get; set; } = 0;

    [MaxLength(512)]
    public string? Notes { get; set; }

    [Required]
    public List<CreateOrderItemDto> Items { get; set; } = new();
}
