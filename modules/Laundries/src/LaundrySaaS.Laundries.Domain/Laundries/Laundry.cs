using System;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Laundries.Laundries;

public class Laundry : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public string Name { get; private set; }
    public string PhoneNumber { get; private set; }
    public Address Address { get; private set; }
    public double? Latitude { get; private set; }
    public double? Longitude { get; private set; }
    public bool IsActive { get; private set; }

    private Laundry()
    {
        Name = string.Empty;
        PhoneNumber = string.Empty;
        Address = null!;
        IsActive = true;
    }

    public Laundry(
        Guid id,
        Guid? tenantId,
        string name,
        string phoneNumber,
        Address address,
        double? latitude = null,
        double? longitude = null,
        bool isActive = true)
        : base(id)
    {
        TenantId = tenantId;
        Name = name;
        PhoneNumber = phoneNumber;
        Address = address;
        Latitude = latitude;
        Longitude = longitude;
        IsActive = isActive;
    }

    public void Update(
        string name,
        string phoneNumber,
        Address address,
        double? latitude,
        double? longitude,
        bool isActive)
    {
        Name = name;
        PhoneNumber = phoneNumber;
        Address = address;
        Latitude = latitude;
        Longitude = longitude;
        IsActive = isActive;
    }
}
