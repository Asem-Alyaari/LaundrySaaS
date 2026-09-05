using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Editions;

public class EditionDto : FullAuditedEntityDto<Guid>
{
    public string DisplayName { get; set; } = string.Empty;
    public string Name => DisplayName;
    public decimal Price { get; set; }
    public decimal AnnualPrice { get; set; }
    public PlanType PlanType { get; set; }
    public bool IsFree { get; set; }
    public int TenantCount { get; set; }
}
