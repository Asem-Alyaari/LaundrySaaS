using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.JournalEntries;
using LaundrySaaS.Accounting.Permissions;
using LaundrySaaS.Accounting.Reports.Dtos;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.Reports;

[Authorize(AccountingPermissions.Reports.Default)]
public class AccountingReportAppService : AccountingAppService, IAccountingReportAppService
{
    private readonly IAccountRepository _accountRepository;
    private readonly IJournalEntryRepository _journalEntryRepository;
    private readonly ICostCenterRepository _costCenterRepository;

    public AccountingReportAppService(
        IAccountRepository accountRepository,
        IJournalEntryRepository journalEntryRepository,
        ICostCenterRepository costCenterRepository)
    {
        _accountRepository = accountRepository;
        _journalEntryRepository = journalEntryRepository;
        _costCenterRepository = costCenterRepository;
    }

    public async Task<TrialBalanceDto> GetTrialBalanceAsync(DateTime? asOfDate = null)
    {
        var accounts = await _accountRepository.GetListAsync();
        var postedEntries = await _journalEntryRepository.GetListWithDetailsAsync(
            endDate: asOfDate,
            status: JournalEntryStatus.Posted
        );

        var report = new TrialBalanceDto
        {
            AsOfDate = asOfDate ?? Clock.Now,
            Items = new List<TrialBalanceItemDto>()
        };

        var allLines = postedEntries.SelectMany(e => e.Lines).ToList();

        foreach (var account in accounts.Where(a => a.AllowDirectPosting).OrderBy(a => a.Code))
        {
            var accountLines = allLines.Where(l => l.AccountId == account.Id).ToList();
            var totalDebit = accountLines.Sum(l => l.Debit);
            var totalCredit = accountLines.Sum(l => l.Credit);

            if (totalDebit == 0 && totalCredit == 0)
            {
                continue; // Skip inactive/empty accounts for clean trial balance
            }

            decimal endingDebit = 0;
            decimal endingCredit = 0;

            if (account.NormalBalance == AccountNormalBalance.Debit)
            {
                var net = totalDebit - totalCredit;
                if (net >= 0) endingDebit = net;
                else endingCredit = Math.Abs(net);
            }
            else
            {
                var net = totalCredit - totalDebit;
                if (net >= 0) endingCredit = net;
                else endingDebit = Math.Abs(net);
            }

            report.Items.Add(new TrialBalanceItemDto
            {
                AccountId = account.Id,
                AccountCode = account.Code,
                AccountName = account.Name,
                AccountType = account.AccountType,
                PeriodDebit = totalDebit,
                PeriodCredit = totalCredit,
                EndingDebit = endingDebit,
                EndingCredit = endingCredit
            });
        }

        report.TotalDebit = report.Items.Sum(i => i.EndingDebit);
        report.TotalCredit = report.Items.Sum(i => i.EndingCredit);

        return report;
    }

    public async Task<AccountStatementDto> GetAccountStatementAsync(GetAccountStatementInput input)
    {
        var account = await _accountRepository.GetAsync(input.AccountId);

        // Calculate opening balance before StartDate
        var openingBalance = await _journalEntryRepository.GetAccountBalanceAsync(
            input.AccountId,
            input.StartDate.AddDays(-1)
        );

        // Fetch entries within period
        var periodEntries = await _journalEntryRepository.GetListWithDetailsAsync(
            startDate: input.StartDate,
            endDate: input.EndDate,
            status: JournalEntryStatus.Posted,
            accountId: input.AccountId
        );

        var costCenterIds = periodEntries
            .SelectMany(e => e.Lines)
            .Where(l => l.CostCenterId.HasValue)
            .Select(l => l.CostCenterId!.Value)
            .Distinct()
            .ToList();

        var costCenters = (await _costCenterRepository.GetListAsync(c => costCenterIds.Contains(c.Id)))
            .ToDictionary(c => c.Id, c => c.Name);

        var statement = new AccountStatementDto
        {
            AccountId = account.Id,
            AccountCode = account.Code,
            AccountName = account.Name,
            StartDate = input.StartDate,
            EndDate = input.EndDate,
            OpeningBalance = openingBalance,
            Items = new List<AccountStatementItemDto>()
        };

        decimal runningBalance = openingBalance;
        decimal totalDebit = 0;
        decimal totalCredit = 0;

        foreach (var entry in periodEntries.OrderBy(e => e.EntryDate).ThenBy(e => e.EntryNumber))
        {
            foreach (var line in entry.Lines.Where(l => l.AccountId == input.AccountId))
            {
                totalDebit += line.Debit;
                totalCredit += line.Credit;

                if (account.NormalBalance == AccountNormalBalance.Debit)
                {
                    runningBalance += (line.Debit - line.Credit);
                }
                else
                {
                    runningBalance += (line.Credit - line.Debit);
                }

                string? costCenterName = null;
                if (line.CostCenterId.HasValue && costCenters.TryGetValue(line.CostCenterId.Value, out var ccName))
                {
                    costCenterName = ccName;
                }

                statement.Items.Add(new AccountStatementItemDto
                {
                    EntryDate = entry.EntryDate,
                    EntryNumber = entry.EntryNumber,
                    Description = line.Description ?? entry.Description,
                    Debit = line.Debit,
                    Credit = line.Credit,
                    RunningBalance = runningBalance,
                    Reference = line.Reference,
                    CostCenterName = costCenterName
                });
            }
        }

        statement.TotalDebit = totalDebit;
        statement.TotalCredit = totalCredit;
        statement.ClosingBalance = runningBalance;

        return statement;
    }
}
