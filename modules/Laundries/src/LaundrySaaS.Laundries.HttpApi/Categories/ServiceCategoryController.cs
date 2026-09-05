using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Laundries.Categories;

[RemoteService(Name = "Laundries")]
[Area("laundries")]
[Route("api/laundries/categories")]
public class ServiceCategoryController : LaundriesController, IServiceCategoryAppService
{
    private readonly IServiceCategoryAppService _categoryAppService;

    public ServiceCategoryController(IServiceCategoryAppService categoryAppService)
    {
        _categoryAppService = categoryAppService;
    }

    [HttpGet]
    public Task<PagedResultDto<ServiceCategoryDto>> GetListAsync([FromQuery] GetServiceCategoriesInput input)
    {
        return _categoryAppService.GetListAsync(input);
    }

    [HttpGet("all")]
    public Task<ListResultDto<ServiceCategoryDto>> GetAllAsync([FromQuery] Guid? laundryId = null)
    {
        return _categoryAppService.GetAllAsync(laundryId);
    }

    [HttpGet("{id}")]
    public Task<ServiceCategoryDto> GetAsync(Guid id)
    {
        return _categoryAppService.GetAsync(id);
    }

    [HttpPost]
    public Task<ServiceCategoryDto> CreateAsync([FromBody] CreateUpdateServiceCategoryDto input)
    {
        return _categoryAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public Task<ServiceCategoryDto> UpdateAsync(Guid id, [FromBody] CreateUpdateServiceCategoryDto input)
    {
        return _categoryAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public Task DeleteAsync(Guid id)
    {
        return _categoryAppService.DeleteAsync(id);
    }
}
