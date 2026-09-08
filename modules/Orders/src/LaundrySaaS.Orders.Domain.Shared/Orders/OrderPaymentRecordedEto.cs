using System;

namespace LaundrySaaS.Orders.Orders;

[Serializable]
public class OrderPaymentRecordedEto
{
    public Guid OrderId { get; set; }
    public Guid? TenantId { get; set; }
    public Guid LaundryId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public Guid? CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal RemainingAmount { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public bool IsDeliverySettlement { get; set; }
    public DateTime PaymentDate { get; set; }
}
