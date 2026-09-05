using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Editions;

[RemoteService(Name = "Saas")]
[Area("saas")]
[Route("api/saas/editions")]
public class EditionController : LaundrySaaSController, IEditionAppService
{
    private readonly IEditionAppService _editionAppService;

    public EditionController(IEditionAppService editionAppService)
    {
        _editionAppService = editionAppService;
    }

    [HttpGet]
    public Task<PagedResultDto<EditionDto>> GetListAsync([FromQuery] GetEditionsInput input)
    {
        return _editionAppService.GetListAsync(input);
    }

    [HttpGet("{id}")]
    public Task<EditionDto> GetAsync(Guid id)
    {
        return _editionAppService.GetAsync(id);
    }

    [HttpPost]
    public Task<EditionDto> CreateAsync([FromBody] CreateEditionDto input)
    {
        return _editionAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public Task<EditionDto> UpdateAsync(Guid id, [FromBody] UpdateEditionDto input)
    {
        return _editionAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public Task DeleteAsync(Guid id)
    {
        return _editionAppService.DeleteAsync(id);
    }
}
