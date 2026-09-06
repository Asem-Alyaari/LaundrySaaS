using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.CostCenters.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.CostCenters;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/cost-centers")]
public class CostCenterController : AccountingController, ICostCenterAppService
{
    private readonly ICostCenterAppService _costCenterAppService;

    public CostCenterController(ICostCenterAppService costCenterAppService)
    {
        _costCenterAppService = costCenterAppService;
    }

    [HttpGet]
    [Route("{id}")]
    public Task<CostCenterDto> GetAsync(Guid id)
    {
        return _costCenterAppService.GetAsync(id);
    }

    [HttpGet]
    public Task<PagedResultDto<CostCenterDto>> GetListAsync(PagedAndSortedResultRequestDto input)
    {
        return _costCenterAppService.GetListAsync(input);
    }

    [HttpGet]
    [Route("by-laundry/{laundryId}")]
    public Task<List<CostCenterDto>> GetByLaundryIdAsync(Guid laundryId)
    {
        return _costCenterAppService.GetByLaundryIdAsync(laundryId);
    }

    [HttpPost]
    public Task<CostCenterDto> CreateAsync(CreateCostCenterDto input)
    {
        return _costCenterAppService.CreateAsync(input);
    }

    [HttpPut]
    [Route("{id}")]
    public Task<CostCenterDto> UpdateAsync(Guid id, UpdateCostCenterDto input)
    {
        return _costCenterAppService.UpdateAsync(id, input);
    }

    [HttpDelete]
    [Route("{id}")]
    public Task DeleteAsync(Guid id)
    {
        return _costCenterAppService.DeleteAsync(id);
    }
}
