using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Drivers.Drivers;

public class DriverDto : FullAuditedEntityDto<Guid>
{
    public Guid? TenantId { get; set; }
    public Guid? LaundryId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string VehicleInfo { get; set; } = string.Empty;
    public bool IsAvailable { get; set; }
}
