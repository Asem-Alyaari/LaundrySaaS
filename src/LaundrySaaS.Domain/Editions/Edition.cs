using System;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;

namespace LaundrySaaS.Editions;

public class Edition : FullAuditedAggregateRoot<Guid>
{
    public string DisplayName { get; private set; }
    public decimal Price { get; private set; }
    public decimal AnnualPrice { get; private set; }
    public PlanType PlanType { get; private set; }
    public bool IsFree { get; private set; }

    private Edition()
    {
        DisplayName = string.Empty;
    }

    public Edition(
        Guid id,
        string displayName,
        decimal price = 0,
        decimal annualPrice = 0,
        PlanType planType = PlanType.Standard,
        bool isFree = false)
        : base(id)
    {
        SetDisplayName(displayName);
        Price = price;
        AnnualPrice = annualPrice;
        PlanType = planType;
        IsFree = isFree;
    }

    public void Update(
        string displayName,
        decimal price,
        decimal annualPrice,
        PlanType planType,
        bool isFree)
    {
        SetDisplayName(displayName);
        Price = price;
        AnnualPrice = annualPrice;
        PlanType = planType;
        IsFree = isFree;
    }

    public void SetDisplayName(string displayName)
    {
        DisplayName = Check.NotNullOrWhiteSpace(displayName, nameof(displayName));
    }
}
