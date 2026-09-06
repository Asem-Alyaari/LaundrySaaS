using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.CostCenters.Dtos;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.CostCenters;

public interface ICostCenterAppService : IApplicationService
{
    Task<CostCenterDto> GetAsync(Guid id);

    Task<PagedResultDto<CostCenterDto>> GetListAsync(PagedAndSortedResultRequestDto input);

    Task<List<CostCenterDto>> GetByLaundryIdAsync(Guid laundryId);

    Task<CostCenterDto> CreateAsync(CreateCostCenterDto input);

    Task<CostCenterDto> UpdateAsync(Guid id, UpdateCostCenterDto input);

    Task DeleteAsync(Guid id);
}
