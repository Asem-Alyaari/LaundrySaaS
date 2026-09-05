using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Categories;

public class GetServiceCategoriesInput : PagedAndSortedResultRequestDto
{
    public string? Filter { get; set; }
    public Guid? LaundryId { get; set; }
}
