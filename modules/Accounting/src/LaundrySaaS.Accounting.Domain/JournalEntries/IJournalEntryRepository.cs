using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.JournalEntries;

public interface IJournalEntryRepository : IRepository<JournalEntry, Guid>
{
    Task<JournalEntry?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);

    Task<List<JournalEntry>> GetListWithDetailsAsync(
        DateTime? startDate = null,
        DateTime? endDate = null,
        JournalEntryStatus? status = null,
        string? sourceModule = null,
        Guid? accountId = null,
        int skipCount = 0,
        int maxResultCount = int.MaxValue,
        CancellationToken cancellationToken = default);

    Task<int> GetNextSequenceAsync(int year, CancellationToken cancellationToken = default);

    Task<decimal> GetAccountBalanceAsync(Guid accountId, DateTime? asOfDate = null, CancellationToken cancellationToken = default);
}
