using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Subscriptions;

public class AssignTenantSubscriptionDto
{
    [Required]
    public Guid TenantId { get; set; }

    [Required]
    public Guid EditionId { get; set; }

    public SubscriptionCycle SubscriptionCycle { get; set; } = SubscriptionCycle.Monthly;
}
