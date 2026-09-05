using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Items;

public class ServiceItemDto : AuditedEntityDto<Guid>
{
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public Guid CategoryId { get; set; }
    public Guid LaundryId { get; set; }
    public bool IsActive { get; set; }
    public string Unit { get; set; } = string.Empty;
    public double DurationHours { get; set; }
    public string? Description { get; set; }
    public string? Icon { get; set; }
}
