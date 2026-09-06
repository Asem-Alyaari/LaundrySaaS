using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Drivers.Drivers;

public class Driver : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public Guid? LaundryId { get; private set; }
    public string FullName { get; private set; }
    public string PhoneNumber { get; private set; }
    public string VehicleInfo { get; private set; }
    public bool IsAvailable { get; private set; }

    private Driver()
    {
        FullName = string.Empty;
        PhoneNumber = string.Empty;
        VehicleInfo = string.Empty;
    }

    public Driver(
        Guid id,
        string fullName,
        string phoneNumber,
        string vehicleInfo,
        bool isAvailable = true,
        Guid? laundryId = null,
        Guid? tenantId = null)
        : base(id)
    {
        FullName = fullName;
        PhoneNumber = phoneNumber;
        VehicleInfo = vehicleInfo;
        IsAvailable = isAvailable;
        LaundryId = laundryId;
        TenantId = tenantId;
    }

    public void Update(
        string fullName,
        string phoneNumber,
        string vehicleInfo,
        bool isAvailable,
        Guid? laundryId = null)
    {
        FullName = fullName;
        PhoneNumber = phoneNumber;
        VehicleInfo = vehicleInfo;
        IsAvailable = isAvailable;
        if (laundryId.HasValue)
        {
            LaundryId = laundryId;
        }
    }

    public void SetAvailability(bool isAvailable)
    {
        IsAvailable = isAvailable;
    }
}
