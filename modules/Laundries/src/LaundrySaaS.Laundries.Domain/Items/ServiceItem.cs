using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Laundries.Items;

public class ServiceItem : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public string Name { get; private set; }
    public decimal Price { get; private set; }
    public Guid CategoryId { get; private set; }
    public Guid LaundryId { get; private set; }
    public bool IsActive { get; private set; }
    public string Unit { get; private set; }
    public double DurationHours { get; private set; }
    public string? Description { get; private set; }
    public string? Icon { get; private set; }

    private ServiceItem()
    {
        Name = string.Empty;
        Unit = "piece";
        IsActive = true;
    }

    public ServiceItem(
        Guid id,
        string name,
        decimal price,
        Guid categoryId,
        Guid laundryId,
        bool isActive = true,
        string unit = "piece",
        double durationHours = 0,
        string? description = null,
        string? icon = null,
        Guid? tenantId = null)
        : base(id)
    {
        Name = name;
        Price = price;
        CategoryId = categoryId;
        LaundryId = laundryId;
        IsActive = isActive;
        Unit = unit;
        DurationHours = durationHours;
        Description = description;
        Icon = icon;
        TenantId = tenantId;
    }

    public void Update(
        string name,
        decimal price,
        Guid categoryId,
        bool isActive,
        string unit = "piece",
        double durationHours = 0,
        string? description = null,
        string? icon = null)
    {
        Name = name;
        Price = price;
        CategoryId = categoryId;
        IsActive = isActive;
        Unit = unit;
        DurationHours = durationHours;
        Description = description;
        Icon = icon;
    }
}
