using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Reports.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.Reports;

public interface IAccountingReportAppService : IApplicationService
{
    Task<TrialBalanceDto> GetTrialBalanceAsync(DateTime? asOfDate = null);

    Task<AccountStatementDto> GetAccountStatementAsync(GetAccountStatementInput input);
}
