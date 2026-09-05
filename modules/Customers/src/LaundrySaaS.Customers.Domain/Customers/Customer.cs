using System;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Domain.Entities.Auditing;

namespace LaundrySaaS.Customers.Customers;

public class Customer : FullAuditedAggregateRoot<Guid>
{
    public string FullName { get; private set; }
    public string PhoneNumber { get; private set; }
    public Address Address { get; private set; }

    private Customer()
    {
        FullName = string.Empty;
        PhoneNumber = string.Empty;
        Address = null!;
    }

    public Customer(Guid id, string fullName, string phoneNumber, Address address)
        : base(id)
    {
        FullName = fullName;
        PhoneNumber = phoneNumber;
        Address = address;
    }

    public void Update(string fullName, string phoneNumber, Address address)
    {
        FullName = fullName;
        PhoneNumber = phoneNumber;
        Address = address;
    }
}
