using System;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Customers.Customers;

public class CustomerAddress : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }
    public Guid CustomerId { get; private set; }
    public string Title { get; private set; }
    public string AddressType { get; private set; } // "home", "work", "other"
    public double Latitude { get; private set; }
    public double Longitude { get; private set; }
    public string Description { get; private set; }
    public string? BuildingOrFloor { get; private set; }
    public string? DeliveryNotes { get; private set; }
    public bool IsDefault { get; private set; }

    private CustomerAddress()
    {
        Title = string.Empty;
        AddressType = "home";
        Description = string.Empty;
    }

    public CustomerAddress(
        Guid id,
        Guid customerId,
        string title,
        string addressType,
        double latitude,
        double longitude,
        string description,
        string? buildingOrFloor = null,
        string? deliveryNotes = null,
        bool isDefault = false,
        Guid? tenantId = null)
        : base(id)
    {
        CustomerId = customerId;
        Title = title;
        AddressType = addressType ?? "home";
        Latitude = latitude;
        Longitude = longitude;
        Description = description ?? string.Empty;
        BuildingOrFloor = buildingOrFloor;
        DeliveryNotes = deliveryNotes;
        IsDefault = isDefault;
        TenantId = tenantId;
    }

    public void Update(
        string title,
        string addressType,
        double latitude,
        double longitude,
        string description,
        string? buildingOrFloor,
        string? deliveryNotes,
        bool isDefault)
    {
        Title = title;
        AddressType = addressType ?? "home";
        Latitude = latitude;
        Longitude = longitude;
        Description = description ?? string.Empty;
        BuildingOrFloor = buildingOrFloor;
        DeliveryNotes = deliveryNotes;
        IsDefault = isDefault;
    }

    public void SetDefault(bool isDefault)
    {
        IsDefault = isDefault;
    }
}
