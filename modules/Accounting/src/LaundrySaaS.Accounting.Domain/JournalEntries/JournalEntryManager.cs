using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.FiscalYears;
using Volo.Abp;
using Volo.Abp.Data;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Services;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.JournalEntries;

public class JournalEntryManager : DomainService
{
    private readonly IJournalEntryRepository _journalEntryRepository;
    private readonly IAccountRepository _accountRepository;
    private readonly IFiscalYearRepository _fiscalYearRepository;
    private readonly IDataFilter _dataFilter;

    public JournalEntryManager(
        IJournalEntryRepository journalEntryRepository,
        IAccountRepository accountRepository,
        IFiscalYearRepository fiscalYearRepository,
        IDataFilter dataFilter)
    {
        _journalEntryRepository = journalEntryRepository;
        _accountRepository = accountRepository;
        _fiscalYearRepository = fiscalYearRepository;
        _dataFilter = dataFilter;
    }

    public async Task<string> GenerateEntryNumberAsync(DateTime entryDate)
    {
        int year = entryDate.Year;
        int nextSeq = await _journalEntryRepository.GetNextSequenceAsync(year);
        return $"JE-{year}-{nextSeq:D6}";
    }

    public async Task ValidateFiscalPeriodOpenAsync(DateTime entryDate)
    {
        var fiscalYear = await _fiscalYearRepository.FindByDateAsync(entryDate);
        if (fiscalYear != null)
        {
            if (fiscalYear.IsClosed || !fiscalYear.IsDateInOpenPeriod(entryDate))
            {
                throw new BusinessException(AccountingErrorCodes.FiscalPeriodClosed)
                    .WithData("Date", entryDate.ToString("yyyy-MM-dd"));
            }
        }
    }

    public async Task ValidateLineAccountAsync(Guid accountId)
    {
        Account? account = null;
        using (_dataFilter.Disable<IMultiTenant>())
        {
            account = await _accountRepository.FindAsync(accountId);
        }

        if (account == null)
        {
            throw new EntityNotFoundException(typeof(Account), accountId);
        }

        if (!account.AllowDirectPosting)
        {
            throw new BusinessException(AccountingErrorCodes.CannotPostToParentAccount)
                .WithData("Account", account.Name)
                .WithData("Code", account.Code);
        }

        if (!account.IsActive)
        {
            throw new BusinessException("Accounting:AccountInactive")
                .WithData("Account", account.Name);
        }
    }

    public async Task PostEntryAsync(JournalEntry entry, Guid userId)
    {
        Check.NotNull(entry, nameof(entry));

        await ValidateFiscalPeriodOpenAsync(entry.EntryDate);

        foreach (var line in entry.Lines)
        {
            await ValidateLineAccountAsync(line.AccountId);
        }

        entry.Post(userId, Clock.Now);
    }
}
