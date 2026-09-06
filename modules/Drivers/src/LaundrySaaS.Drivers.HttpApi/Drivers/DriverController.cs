using System;
using System.Threading.Tasks;
using Asp.Versioning;
using LaundrySaaS.Drivers.Drivers;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Drivers.Drivers;

[RemoteService(Name = "Drivers")]
[Area("drivers")]
[ControllerName("Driver")]
[Route("api/drivers/drivers")]
public class DriverController : DriversController, IDriverAppService
{
    private readonly IDriverAppService _driverAppService;

    public DriverController(IDriverAppService driverAppService)
    {
        _driverAppService = driverAppService;
    }

    [HttpGet]
    public virtual Task<PagedResultDto<DriverDto>> GetListAsync(GetDriversInputDto input)
    {
        return _driverAppService.GetListAsync(input);
    }

    [HttpGet("{id}")]
    public virtual Task<DriverDto> GetAsync(Guid id)
    {
        return _driverAppService.GetAsync(id);
    }

    [HttpPost]
    public virtual Task<DriverDto> CreateAsync(CreateUpdateDriverDto input)
    {
        return _driverAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public virtual Task<DriverDto> UpdateAsync(Guid id, CreateUpdateDriverDto input)
    {
        return _driverAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public virtual Task DeleteAsync(Guid id)
    {
        return _driverAppService.DeleteAsync(id);
    }

    [HttpPost("{id}/toggle-availability")]
    public virtual Task SetAvailabilityAsync(Guid id, [FromQuery] bool isAvailable)
    {
        return _driverAppService.SetAvailabilityAsync(id, isAvailable);
    }
}
