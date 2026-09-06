using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.FiscalYears;
using LaundrySaaS.Accounting.JournalEntries;
using LaundrySaaS.Accounting.Parties;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

[ConnectionStringName(AccountingDbProperties.ConnectionStringName)]
public interface IAccountingDbContext : IEfCoreDbContext
{
    DbSet<Account> Accounts { get; }
    DbSet<FiscalYear> FiscalYears { get; }
    DbSet<FiscalPeriod> FiscalPeriods { get; }
    DbSet<CostCenter> CostCenters { get; }
    DbSet<JournalEntry> JournalEntries { get; }
    DbSet<JournalEntryLine> JournalEntryLines { get; }
    DbSet<PartyAccount> PartyAccounts { get; }
}
