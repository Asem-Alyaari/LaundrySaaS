using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Drivers.Drivers;

public interface IDriverAppService :
    ICrudAppService<
        DriverDto,
        Guid,
        GetDriversInputDto,
        CreateUpdateDriverDto>
{
    Task SetAvailabilityAsync(Guid id, bool isAvailable);
}
