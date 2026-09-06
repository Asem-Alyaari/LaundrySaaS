using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.JournalEntries;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public class EfCoreJournalEntryRepository : EfCoreRepository<IAccountingDbContext, JournalEntry, Guid>, IJournalEntryRepository
{
    public EfCoreJournalEntryRepository(IDbContextProvider<IAccountingDbContext> dbContextProvider)
        : base(dbContextProvider)
    {

    }

    public async Task<JournalEntry?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet
            .Include(j => j.Lines)
            .FirstOrDefaultAsync(j => j.Id == id, cancellationToken);
    }

    public async Task<List<JournalEntry>> GetListWithDetailsAsync(
        DateTime? startDate = null,
        DateTime? endDate = null,
        JournalEntryStatus? status = null,
        string? sourceModule = null,
        Guid? accountId = null,
        int skipCount = 0,
        int maxResultCount = int.MaxValue,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        var query = dbSet.Include(j => j.Lines).AsQueryable();

        if (startDate.HasValue)
        {
            query = query.Where(j => j.EntryDate >= startDate.Value);
        }

        if (endDate.HasValue)
        {
            query = query.Where(j => j.EntryDate <= endDate.Value);
        }

        if (status.HasValue)
        {
            query = query.Where(j => j.Status == status.Value);
        }

        if (!string.IsNullOrWhiteSpace(sourceModule))
        {
            query = query.Where(j => j.SourceModule == sourceModule);
        }

        if (accountId.HasValue)
        {
            query = query.Where(j => j.Lines.Any(l => l.AccountId == accountId.Value));
        }

        return await query
            .OrderByDescending(j => j.EntryDate)
            .ThenByDescending(j => j.EntryNumber)
            .Skip(skipCount)
            .Take(maxResultCount)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetNextSequenceAsync(int year, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        var count = await dbSet.CountAsync(j => j.EntryDate.Year == year, cancellationToken);
        return count + 1;
    }

    public async Task<decimal> GetAccountBalanceAsync(Guid accountId, DateTime? asOfDate = null, CancellationToken cancellationToken = default)
    {
        var dbContext = await GetDbContextAsync();
        var query = dbContext.JournalEntries
            .Where(j => j.Status == JournalEntryStatus.Posted)
            .AsQueryable();

        if (asOfDate.HasValue)
        {
            query = query.Where(j => j.EntryDate <= asOfDate.Value);
        }

        var linesQuery = from entry in query
                         from line in entry.Lines
                         where line.AccountId == accountId
                         select new { line.Debit, line.Credit };

        var totals = await linesQuery.ToListAsync(cancellationToken);
        var totalDebit = totals.Sum(x => x.Debit);
        var totalCredit = totals.Sum(x => x.Credit);

        return totalDebit - totalCredit;
    }
}
