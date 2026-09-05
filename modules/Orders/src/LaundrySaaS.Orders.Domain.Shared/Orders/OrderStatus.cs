namespace LaundrySaaS.Orders.Orders;

public enum OrderStatus
{
    Pending = 1,
    Confirmed = 2,
    PickedUp = 3,
    Processing = 4,
    OutForDelivery = 5,
    Delivered = 6,
    Cancelled = 7
}
