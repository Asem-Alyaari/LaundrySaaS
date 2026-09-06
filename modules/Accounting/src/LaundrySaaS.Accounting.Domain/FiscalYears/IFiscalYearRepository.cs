using System;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.FiscalYears;

public interface IFiscalYearRepository : IRepository<FiscalYear, Guid>
{
    Task<FiscalYear?> FindByDateAsync(DateTime date, CancellationToken cancellationToken = default);

    Task<FiscalYear?> GetWithPeriodsAsync(Guid id, CancellationToken cancellationToken = default);
}
