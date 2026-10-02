using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Laundries;

[RemoteService(Name = "Laundries")]
[Area("laundries")]
[Route("api/laundries")]
[Route("api/app/laundry")]
public class LaundryController : LaundriesController, ILaundryAppService
{
    private readonly ILaundryAppService _laundryAppService;

    public LaundryController(ILaundryAppService laundryAppService)
    {
        _laundryAppService = laundryAppService;
    }

    [HttpGet]
    public virtual Task<PagedResultDto<LaundryDto>> GetListAsync([FromQuery] PagedAndSortedResultRequestDto input)
    {
        return _laundryAppService.GetListAsync(input);
    }

    [HttpGet("{id}")]
    public virtual Task<LaundryDto> GetAsync(Guid id)
    {
        return _laundryAppService.GetAsync(id);
    }

    [HttpGet("nearby")]
    public virtual Task<List<LaundryDto>> GetNearbyAsync(
        [FromQuery] double lat,
        [FromQuery] double lng,
        [FromQuery] double radiusKm = 10)
    {
        return _laundryAppService.GetNearbyAsync(lat, lng, radiusKm);
    }

    [HttpPost]
    public virtual Task<LaundryDto> CreateAsync([FromBody] CreateUpdateLaundryDto input)
    {
        return _laundryAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public virtual Task<LaundryDto> UpdateAsync(Guid id, [FromBody] CreateUpdateLaundryDto input)
    {
        return _laundryAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public virtual Task DeleteAsync(Guid id)
    {
        return _laundryAppService.DeleteAsync(id);
    }
}

