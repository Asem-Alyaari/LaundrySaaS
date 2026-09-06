using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.FiscalYears.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;

namespace LaundrySaaS.Accounting.FiscalYears;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/fiscal-years")]
public class FiscalYearController : AccountingController, IFiscalYearAppService
{
    private readonly IFiscalYearAppService _fiscalYearAppService;

    public FiscalYearController(IFiscalYearAppService fiscalYearAppService)
    {
        _fiscalYearAppService = fiscalYearAppService;
    }

    [HttpGet]
    [Route("{id}")]
    public Task<FiscalYearDto> GetAsync(Guid id)
    {
        return _fiscalYearAppService.GetAsync(id);
    }

    [HttpGet]
    public Task<List<FiscalYearDto>> GetListAsync()
    {
        return _fiscalYearAppService.GetListAsync();
    }

    [HttpPost]
    public Task<FiscalYearDto> CreateAsync(CreateFiscalYearDto input)
    {
        return _fiscalYearAppService.CreateAsync(input);
    }

    [HttpPost]
    [Route("{id}/periods/{periodNumber}/close")]
    public Task<FiscalYearDto> ClosePeriodAsync(Guid id, int periodNumber)
    {
        return _fiscalYearAppService.ClosePeriodAsync(id, periodNumber);
    }

    [HttpPost]
    [Route("{id}/periods/{periodNumber}/reopen")]
    public Task<FiscalYearDto> ReopenPeriodAsync(Guid id, int periodNumber)
    {
        return _fiscalYearAppService.ReopenPeriodAsync(id, periodNumber);
    }

    [HttpPost]
    [Route("{id}/close")]
    public Task<FiscalYearDto> CloseYearAsync(Guid id)
    {
        return _fiscalYearAppService.CloseYearAsync(id);
    }
}
