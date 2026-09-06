using LaundrySaaS.Drivers.Drivers;
using Riok.Mapperly.Abstractions;
using Volo.Abp.Mapperly;

namespace LaundrySaaS.Drivers;

[Mapper]
public partial class DriversApplicationMappers
{
    public partial DriverDto ToDto(Driver source);
}
