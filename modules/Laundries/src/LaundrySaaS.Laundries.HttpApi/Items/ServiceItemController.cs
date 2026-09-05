using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Items;

[RemoteService(Name = "Laundries")]
[Area("laundries")]
[Route("api/laundries/items")]
public class ServiceItemController : LaundriesController, IServiceItemAppService
{
    private readonly IServiceItemAppService _itemAppService;

    public ServiceItemController(IServiceItemAppService itemAppService)
    {
        _itemAppService = itemAppService;
    }

    [HttpGet]
    public Task<PagedResultDto<ServiceItemDto>> GetListAsync([FromQuery] GetServiceItemsInput input)
    {
        return _itemAppService.GetListAsync(input);
    }

    [HttpGet("{id}")]
    public Task<ServiceItemDto> GetAsync(Guid id)
    {
        return _itemAppService.GetAsync(id);
    }

    [HttpPost]
    public Task<ServiceItemDto> CreateAsync([FromBody] CreateUpdateServiceItemDto input)
    {
        return _itemAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public Task<ServiceItemDto> UpdateAsync(Guid id, [FromBody] CreateUpdateServiceItemDto input)
    {
        return _itemAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public Task DeleteAsync(Guid id)
    {
        return _itemAppService.DeleteAsync(id);
    }

    [HttpPost("import-template/{laundryId}")]
    public Task<List<ServiceItemDto>> ImportTemplateCatalogAsync(Guid laundryId)
    {
        return _itemAppService.ImportTemplateCatalogAsync(laundryId);
    }
}
