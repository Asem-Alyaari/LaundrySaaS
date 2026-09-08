using System;

namespace LaundrySaaS.Orders.Orders;

[Serializable]
public class OrderCreatedEto
{
    public Guid OrderId { get; set; }
    public Guid? TenantId { get; set; }
    public Guid LaundryId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public Guid? CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public PaymentStatus PaymentStatus { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public DateTime CreationTime { get; set; }
}
