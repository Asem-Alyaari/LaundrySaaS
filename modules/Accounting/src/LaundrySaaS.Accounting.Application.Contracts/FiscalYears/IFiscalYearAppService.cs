using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.FiscalYears.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.FiscalYears;

public interface IFiscalYearAppService : IApplicationService
{
    Task<FiscalYearDto> GetAsync(Guid id);

    Task<List<FiscalYearDto>> GetListAsync();

    Task<FiscalYearDto> CreateAsync(CreateFiscalYearDto input);

    Task<FiscalYearDto> ClosePeriodAsync(Guid id, int periodNumber);

    Task<FiscalYearDto> ReopenPeriodAsync(Guid id, int periodNumber);

    Task<FiscalYearDto> CloseYearAsync(Guid id);
}
