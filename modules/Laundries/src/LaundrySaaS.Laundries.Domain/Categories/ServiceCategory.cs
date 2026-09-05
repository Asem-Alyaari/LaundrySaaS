using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Laundries.Categories;

public class ServiceCategory : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public string Name { get; private set; }
    public Guid LaundryId { get; private set; }
    public string? Icon { get; private set; }
    public string? Color { get; private set; }
    public int DisplayOrder { get; private set; }

    private ServiceCategory()
    {
        Name = string.Empty;
        DisplayOrder = 0;
    }

    public ServiceCategory(
        Guid id,
        string name,
        Guid laundryId,
        string? icon = null,
        string? color = null,
        int displayOrder = 0,
        Guid? tenantId = null)
        : base(id)
    {
        Name = name;
        LaundryId = laundryId;
        Icon = icon;
        Color = color;
        DisplayOrder = displayOrder;
        TenantId = tenantId;
    }

    public void Update(
        string name,
        string? icon = null,
        string? color = null,
        int displayOrder = 0)
    {
        Name = name;
        Icon = icon;
        Color = color;
        DisplayOrder = displayOrder;
    }
}
