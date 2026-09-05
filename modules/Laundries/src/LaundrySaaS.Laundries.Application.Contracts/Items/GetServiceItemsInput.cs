using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Items;

public class GetServiceItemsInput : PagedAndSortedResultRequestDto
{
    public string? Filter { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid? LaundryId { get; set; }
}
