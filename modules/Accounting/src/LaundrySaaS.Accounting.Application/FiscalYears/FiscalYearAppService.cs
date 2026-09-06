using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.FiscalYears.Dtos;
using LaundrySaaS.Accounting.Permissions;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.FiscalYears;

[Authorize(AccountingPermissions.FiscalYears.Default)]
public class FiscalYearAppService : AccountingAppService, IFiscalYearAppService
{
    private readonly IFiscalYearRepository _fiscalYearRepository;
    private readonly AccountingApplicationMappers _mapper;

    public FiscalYearAppService(
        IFiscalYearRepository fiscalYearRepository,
        AccountingApplicationMappers mapper)
    {
        _fiscalYearRepository = fiscalYearRepository;
        _mapper = mapper;
    }

    public async Task<FiscalYearDto> GetAsync(Guid id)
    {
        var year = await _fiscalYearRepository.GetWithPeriodsAsync(id);
        if (year == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:FiscalYearNotFound");
        }

        return MapWithPeriods(year);
    }

    public async Task<List<FiscalYearDto>> GetListAsync()
    {
        var years = await _fiscalYearRepository.GetListAsync();
        return years.OrderByDescending(y => y.StartDate).Select(MapWithPeriods).ToList();
    }

    [Authorize(AccountingPermissions.FiscalYears.Manage)]
    public async Task<FiscalYearDto> CreateAsync(CreateFiscalYearDto input)
    {
        var year = new FiscalYear(
            GuidGenerator.Create(),
            CurrentTenant.Id,
            input.Name,
            input.StartDate,
            input.EndDate
        );

        await _fiscalYearRepository.InsertAsync(year);
        return MapWithPeriods(year);
    }

    [Authorize(AccountingPermissions.FiscalYears.Manage)]
    public async Task<FiscalYearDto> ClosePeriodAsync(Guid id, int periodNumber)
    {
        var year = await _fiscalYearRepository.GetWithPeriodsAsync(id);
        if (year == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:FiscalYearNotFound");
        }

        year.ClosePeriod(periodNumber);
        await _fiscalYearRepository.UpdateAsync(year);
        return MapWithPeriods(year);
    }

    [Authorize(AccountingPermissions.FiscalYears.Manage)]
    public async Task<FiscalYearDto> ReopenPeriodAsync(Guid id, int periodNumber)
    {
        var year = await _fiscalYearRepository.GetWithPeriodsAsync(id);
        if (year == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:FiscalYearNotFound");
        }

        year.ReopenPeriod(periodNumber);
        await _fiscalYearRepository.UpdateAsync(year);
        return MapWithPeriods(year);
    }

    [Authorize(AccountingPermissions.FiscalYears.Manage)]
    public async Task<FiscalYearDto> CloseYearAsync(Guid id)
    {
        var year = await _fiscalYearRepository.GetWithPeriodsAsync(id);
        if (year == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:FiscalYearNotFound");
        }

        year.Close();
        await _fiscalYearRepository.UpdateAsync(year);
        return MapWithPeriods(year);
    }

    private FiscalYearDto MapWithPeriods(FiscalYear year)
    {
        var dto = _mapper.ToDto(year);
        dto.Periods = year.Periods
            .OrderBy(p => p.PeriodNumber)
            .Select(_mapper.ToDto)
            .ToList();
        return dto;
    }
}
