using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Customers.Customers;

public class CreateUpdateCustomerDto
{
    [Required]
    [MaxLength(128)]
    public string FullName { get; set; } = string.Empty;

    [Required]
    [MaxLength(32)]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required]
    public CreateUpdateAddressDto Address { get; set; } = default!;
}

public class CreateUpdateAddressDto
{
    [Required]
    [MaxLength(64)]
    public string City { get; set; } = string.Empty;

    [Required]
    [MaxLength(64)]
    public string District { get; set; } = string.Empty;

    [Required]
    [MaxLength(128)]
    public string Street { get; set; } = string.Empty;

    [Required]
    [MaxLength(16)]
    public string BuildingNumber { get; set; } = string.Empty;
}
