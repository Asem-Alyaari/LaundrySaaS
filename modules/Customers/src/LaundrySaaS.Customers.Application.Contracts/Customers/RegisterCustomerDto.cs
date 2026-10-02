using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Customers.Customers;

public class RegisterCustomerDto
{
    [Required]
    [MaxLength(128)]
    public string FullName { get; set; } = string.Empty;

    [Required]
    [MaxLength(32)]
    public string PhoneNumber { get; set; } = string.Empty;

    [MaxLength(128)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    [MaxLength(128)]
    public string Password { get; set; } = string.Empty;
}
