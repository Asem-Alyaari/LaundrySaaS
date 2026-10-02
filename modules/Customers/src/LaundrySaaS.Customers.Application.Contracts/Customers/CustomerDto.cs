using System;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Customers.Customers;

public class CustomerDto : AuditedEntityDto<Guid>
{
    public string FullName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public AddressDto Address { get; set; } = default!;
}

public class AddressDto
{
    public string City { get; set; } = string.Empty;
    public string District { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string BuildingNumber { get; set; } = string.Empty;
}
