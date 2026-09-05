using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using LaundrySaaS.Laundries.Laundries;
using LaundrySaaS.ValueObjects;
using Riok.Mapperly.Abstractions;

namespace LaundrySaaS.Laundries;

[Mapper]
public partial class LaundriesApplicationMappers
{
    // Read-direction: domain → DTO
    public partial LaundryDto ToDto(Laundry source);
    public partial AddressDto ToDto(Address source);
    public partial ServiceCategoryDto ToDto(ServiceCategory source);
    public partial ServiceItemDto ToDto(ServiceItem source);
}
