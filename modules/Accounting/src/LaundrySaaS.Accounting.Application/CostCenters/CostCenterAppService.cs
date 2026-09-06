using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.CostCenters.Dtos;
using LaundrySaaS.Accounting.Permissions;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.CostCenters;

[Authorize(AccountingPermissions.CostCenters.Default)]
public class CostCenterAppService : AccountingAppService, ICostCenterAppService
{
    private readonly ICostCenterRepository _costCenterRepository;
    private readonly AccountingApplicationMappers _mapper;

    public CostCenterAppService(
        ICostCenterRepository costCenterRepository,
        AccountingApplicationMappers mapper)
    {
        _costCenterRepository = costCenterRepository;
        _mapper = mapper;
    }

    public async Task<CostCenterDto> GetAsync(Guid id)
    {
        var costCenter = await _costCenterRepository.GetAsync(id);
        return _mapper.ToDto(costCenter);
    }

    public async Task<PagedResultDto<CostCenterDto>> GetListAsync(PagedAndSortedResultRequestDto input)
    {
        var totalCount = await _costCenterRepository.GetCountAsync();
        var items = await _costCenterRepository.GetPagedListAsync(
            input.SkipCount,
            input.MaxResultCount,
            input.Sorting ?? nameof(CostCenter.Code)
        );

        return new PagedResultDto<CostCenterDto>(
            totalCount,
            items.Select(_mapper.ToDto).ToList()
        );
    }

    public async Task<List<CostCenterDto>> GetByLaundryIdAsync(Guid laundryId)
    {
        var items = await _costCenterRepository.GetByLaundryIdAsync(laundryId);
        return items.Select(_mapper.ToDto).ToList();
    }

    [Authorize(AccountingPermissions.CostCenters.Manage)]
    public async Task<CostCenterDto> CreateAsync(CreateCostCenterDto input)
    {
        var existing = await _costCenterRepository.FindByCodeAsync(input.Code);
        if (existing != null)
        {
            throw new Volo.Abp.BusinessException(AccountingErrorCodes.AccountCodeAlreadyExists)
                .WithData("Code", input.Code);
        }

        var costCenter = new CostCenter(
            GuidGenerator.Create(),
            CurrentTenant.Id,
            input.Code,
            input.Name,
            input.ParentId,
            input.LaundryId,
            input.IsActive
        );

        await _costCenterRepository.InsertAsync(costCenter);
        return _mapper.ToDto(costCenter);
    }

    [Authorize(AccountingPermissions.CostCenters.Manage)]
    public async Task<CostCenterDto> UpdateAsync(Guid id, UpdateCostCenterDto input)
    {
        var costCenter = await _costCenterRepository.GetAsync(id);

        costCenter.Update(
            input.Name,
            input.ParentId,
            input.LaundryId,
            input.IsActive
        );

        await _costCenterRepository.UpdateAsync(costCenter);
        return _mapper.ToDto(costCenter);
    }

    [Authorize(AccountingPermissions.CostCenters.Manage)]
    public async Task DeleteAsync(Guid id)
    {
        await _costCenterRepository.DeleteAsync(id);
    }
}
