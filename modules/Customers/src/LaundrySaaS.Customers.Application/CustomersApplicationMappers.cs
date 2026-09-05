using LaundrySaaS.Customers.Customers;
using LaundrySaaS.ValueObjects;
using Riok.Mapperly.Abstractions;

namespace LaundrySaaS.Customers;

[Mapper]
public partial class CustomersApplicationMappers
{
    // Read-direction: domain → DTO
    public partial CustomerDto ToDto(Customer source);
    public partial AddressDto ToDto(Address source);
}
