using System.Collections.Generic;
using Volo.Abp.Domain.Values;

namespace LaundrySaaS.ValueObjects;

public class Address : ValueObject
{
    public string City { get; private set; }
    public string District { get; private set; }
    public string Street { get; private set; }
    public string BuildingNumber { get; private set; }

    private Address()
    {
        City = string.Empty;
        District = string.Empty;
        Street = string.Empty;
        BuildingNumber = string.Empty;
    }

    public Address(string city, string district, string street, string buildingNumber)
    {
        City = city;
        District = district;
        Street = street;
        BuildingNumber = buildingNumber;
    }

    protected override IEnumerable<object> GetAtomicValues()
    {
        yield return City;
        yield return District;
        yield return Street;
        yield return BuildingNumber;
    }
}
