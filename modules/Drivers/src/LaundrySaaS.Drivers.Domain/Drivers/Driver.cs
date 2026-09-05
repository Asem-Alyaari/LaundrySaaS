using System;
using Volo.Abp.Domain.Entities.Auditing;

namespace LaundrySaaS.Drivers.Drivers;

public class Driver : FullAuditedAggregateRoot<Guid>
{
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

    public Driver(Guid id, string fullName, string phoneNumber, string vehicleInfo, bool isAvailable = true)
        : base(id)
    {
        FullName = fullName;
        PhoneNumber = phoneNumber;
        VehicleInfo = vehicleInfo;
        IsAvailable = isAvailable;
    }
}
