using System;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.CostCenters;

public class CostCenter : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }

    public string Code { get; private set; }

    public string Name { get; private set; }

    public Guid? ParentId { get; private set; }

    public Guid? LaundryId { get; private set; }

    public bool IsActive { get; private set; }

    private CostCenter()
    {
        Code = string.Empty;
        Name = string.Empty;
        IsActive = true;
    }

    public CostCenter(
        Guid id,
        Guid? tenantId,
        string code,
        string name,
        Guid? parentId = null,
        Guid? laundryId = null,
        bool isActive = true)
        : base(id)
    {
        TenantId = tenantId;
        Code = Check.NotNullOrWhiteSpace(code, nameof(code), maxLength: 64);
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 256);
        ParentId = parentId;
        LaundryId = laundryId;
        IsActive = isActive;
    }

    public void Update(string name, Guid? parentId, Guid? laundryId, bool isActive)
    {
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 256);
        ParentId = parentId;
        LaundryId = laundryId;
        IsActive = isActive;
    }
}
