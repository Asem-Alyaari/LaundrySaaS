using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Customers.Customers;

public class CreateUpdateCustomerAddressDto
{
    [Required]
    [MaxLength(128)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MaxLength(32)]
    public string AddressType { get; set; } = "home";

    [Required]
    public double Latitude { get; set; }

    [Required]
    public double Longitude { get; set; }

    [MaxLength(256)]
    public string Description { get; set; } = string.Empty;

    [MaxLength(128)]
    public string? BuildingOrFloor { get; set; }

    [MaxLength(256)]
    public string? DeliveryNotes { get; set; }

    public bool IsDefault { get; set; }
}
