using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Orders.Orders;

public class OrderItemDto : EntityDto<Guid>
{
    public Guid OrderId { get; set; }
    public Guid ServiceItemId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
    public decimal TotalPrice { get; set; }
    public string? Notes { get; set; }
}

public class CreateOrderItemDto
{
    public Guid ServiceItemId { get; set; }
    public string ItemName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; } = 1;
    public string? Notes { get; set; }
}
