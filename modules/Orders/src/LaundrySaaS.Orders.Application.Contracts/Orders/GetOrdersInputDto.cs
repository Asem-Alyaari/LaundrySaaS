using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Orders.Orders;

public class GetOrdersInputDto : PagedAndSortedResultRequestDto
{
    public Guid? LaundryId { get; set; }
    public OrderStatus? Status { get; set; }
    public PaymentStatus? PaymentStatus { get; set; }
    public bool? IsWalkIn { get; set; }
    public string? Filter { get; set; }
}
