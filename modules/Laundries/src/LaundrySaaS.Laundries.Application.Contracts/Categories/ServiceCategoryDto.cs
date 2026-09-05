using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Categories;

public class ServiceCategoryDto : AuditedEntityDto<Guid>
{
    public string Name { get; set; } = string.Empty;
    public Guid LaundryId { get; set; }
    public string? Icon { get; set; }
    public string? Color { get; set; }
    public int DisplayOrder { get; set; }
}
