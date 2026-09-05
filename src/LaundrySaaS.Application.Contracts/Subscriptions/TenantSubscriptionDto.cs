using System;
using LaundrySaaS.Editions;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Subscriptions;

public class TenantSubscriptionDto : FullAuditedEntityDto<Guid>
{
    public Guid? TenantId { get; set; }
    public Guid EditionId { get; set; }
    public string? EditionName { get; set; }
    public EditionDto? Edition { get; set; }
    public SubscriptionCycle SubscriptionCycle { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime ExpireDate { get; set; }
    public SubscriptionStatus Status { get; set; }
}
