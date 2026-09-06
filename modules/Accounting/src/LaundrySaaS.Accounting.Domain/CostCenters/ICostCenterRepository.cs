using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.CostCenters;

public interface ICostCenterRepository : IRepository<CostCenter, Guid>
{
    Task<CostCenter?> FindByCodeAsync(string code, CancellationToken cancellationToken = default);

    Task<List<CostCenter>> GetByLaundryIdAsync(Guid laundryId, CancellationToken cancellationToken = default);
}
