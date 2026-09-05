namespace LaundrySaaS.Orders;

public enum OrderStatus
{
    Pending = 1,
    Accepted = 2,
    PickupAssigned = 3,
    PickedUp = 4,
    AtLaundry = 5,
    Processing = 6,
    Ready = 7,
    DeliveryAssigned = 8,
    OutForDelivery = 9,
    Delivered = 10,
    Cancelled = 11,
    PickupFailed = 12,
    DeliveryFailed = 13
}
