using System;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Domain.Entities.Auditing;

namespace LaundrySaaS.Orders.Orders;

public class Order : FullAuditedAggregateRoot<Guid>
{
    public Guid CustomerId { get; private set; }
    public Guid? DriverId { get; private set; }
    public OrderStatus Status { get; private set; }
    public decimal TotalAmount { get; private set; }
    public Address DeliveryAddress { get; private set; }

    private Order()
    {
        DeliveryAddress = null!;
    }

    public Order(
        Guid id,
        Guid customerId,
        Address deliveryAddress,
        decimal totalAmount = 0,
        Guid? driverId = null,
        OrderStatus status = OrderStatus.Pending)
        : base(id)
    {
        CustomerId = customerId;
        DeliveryAddress = deliveryAddress;
        TotalAmount = totalAmount;
        DriverId = driverId;
        Status = status;
    }
}
