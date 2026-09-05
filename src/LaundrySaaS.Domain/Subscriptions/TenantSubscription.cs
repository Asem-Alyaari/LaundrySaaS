using System;
using LaundrySaaS.Editions;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Subscriptions;

public class TenantSubscription : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; private set; }
    public Guid EditionId { get; private set; }
    public virtual Edition? Edition { get; private set; }
    public SubscriptionCycle SubscriptionCycle { get; private set; }
    public DateTime StartDate { get; private set; }
    public DateTime ExpireDate { get; private set; }
    public SubscriptionStatus Status { get; private set; }

    private TenantSubscription()
    {
    }

    public TenantSubscription(
        Guid id,
        Guid? tenantId,
        Guid editionId,
        SubscriptionCycle subscriptionCycle,
        DateTime startDate,
        DateTime expireDate,
        SubscriptionStatus status = SubscriptionStatus.Active)
        : base(id)
    {
        TenantId = tenantId;
        EditionId = editionId;
        SubscriptionCycle = subscriptionCycle;
        StartDate = startDate;
        ExpireDate = expireDate;
        Status = status;
    }

    public void Update(
        Guid editionId,
        SubscriptionCycle subscriptionCycle,
        DateTime startDate,
        DateTime expireDate,
        SubscriptionStatus status)
    {
        EditionId = editionId;
        SubscriptionCycle = subscriptionCycle;
        StartDate = startDate;
        ExpireDate = expireDate;
        Status = status;
    }

    public void Renew(DateTime newExpireDate)
    {
        ExpireDate = newExpireDate;
        Status = SubscriptionStatus.Active;
    }

    public void Suspend()
    {
        Status = SubscriptionStatus.Suspended;
    }

    public void Expire()
    {
        Status = SubscriptionStatus.Expired;
    }

    public void Activate()
    {
        Status = SubscriptionStatus.Active;
    }
}
