using System;

namespace LaundrySaaS.Customers.Customers;

public class RegisterCustomerResultDto
{
    public Guid CustomerId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool Success { get; set; }
    public string? ErrorMessage { get; set; }
}
