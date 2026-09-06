namespace LaundrySaaS.Orders.Orders;

public enum PaymentStatus
{
    Unpaid = 1,
    Paid = 2,
    PartiallyPaid = 3
}

public enum PaymentMethod
{
    Cash = 1,
    Card = 2,
    Transfer = 3,
    OnDelivery = 4,
    Later = 5
}

public enum OrderDeliveryType
{
    InStore = 1,
    Delivery = 2
}
