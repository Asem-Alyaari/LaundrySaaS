using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Reports.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;

namespace LaundrySaaS.Accounting.Reports;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/reports")]
public class AccountingReportController : AccountingController, IAccountingReportAppService
{
    private readonly IAccountingReportAppService _reportAppService;

    public AccountingReportController(IAccountingReportAppService reportAppService)
    {
        _reportAppService = reportAppService;
    }

    [HttpGet]
    [Route("trial-balance")]
    public Task<TrialBalanceDto> GetTrialBalanceAsync(DateTime? asOfDate = null)
    {
        return _reportAppService.GetTrialBalanceAsync(asOfDate);
    }

    [HttpPost]
    [Route("account-statement")]
    public Task<AccountStatementDto> GetAccountStatementAsync(GetAccountStatementInput input)
    {
        return _reportAppService.GetAccountStatementAsync(input);
    }
}
