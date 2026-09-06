using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Drivers.Drivers;

public class CreateUpdateDriverDto
{
    [Required]
    [StringLength(128)]
    public string FullName { get; set; } = string.Empty;

    [Required]
    [StringLength(32)]
    public string PhoneNumber { get; set; } = string.Empty;

    [StringLength(256)]
    public string VehicleInfo { get; set; } = string.Empty;

    public bool IsAvailable { get; set; } = true;

    public System.Guid? LaundryId { get; set; }
}
