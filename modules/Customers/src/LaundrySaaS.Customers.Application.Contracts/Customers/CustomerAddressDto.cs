using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Customers.Customers;

public class CustomerAddressDto : FullAuditedEntityDto<Guid>
{
    public Guid CustomerId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string AddressType { get; set; } = "home";
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? BuildingOrFloor { get; set; }
    public string? DeliveryNotes { get; set; }
    public bool IsDefault { get; set; }
}
