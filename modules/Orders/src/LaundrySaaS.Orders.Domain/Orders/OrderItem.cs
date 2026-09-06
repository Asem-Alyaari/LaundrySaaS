using System;
using Volo.Abp.Domain.Entities.Auditing;

namespace LaundrySaaS.Orders.Orders;

public class OrderItem : FullAuditedEntity<Guid>
{
    public Guid OrderId { get; private set; }
    public Guid ServiceItemId { get; private set; }
    public string ItemName { get; private set; }
    public decimal UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public decimal TotalPrice { get; private set; }
    public string? Notes { get; private set; }

    private OrderItem()
    {
        ItemName = string.Empty;
    }

    public OrderItem(
        Guid id,
        Guid orderId,
        Guid serviceItemId,
        string itemName,
        decimal unitPrice,
        int quantity,
        string? notes = null)
        : base(id)
    {
        OrderId = orderId;
        ServiceItemId = serviceItemId;
        ItemName = itemName;
        UnitPrice = unitPrice;
        Quantity = quantity <= 0 ? 1 : quantity;
        TotalPrice = UnitPrice * Quantity;
        Notes = notes;
    }

    public void UpdateQuantity(int quantity)
    {
        Quantity = quantity <= 0 ? 1 : quantity;
        TotalPrice = UnitPrice * Quantity;
    }

    public void SetNotes(string? notes)
    {
        Notes = notes;
    }
}
