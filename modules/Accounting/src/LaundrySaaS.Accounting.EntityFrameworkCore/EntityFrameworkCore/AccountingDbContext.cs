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
public class AccountingDbContext : AbpDbContext<AccountingDbContext>, IAccountingDbContext
{
    public DbSet<Account> Accounts { get; set; } = null!;
    public DbSet<FiscalYear> FiscalYears { get; set; } = null!;
    public DbSet<FiscalPeriod> FiscalPeriods { get; set; } = null!;
    public DbSet<CostCenter> CostCenters { get; set; } = null!;
    public DbSet<JournalEntry> JournalEntries { get; set; } = null!;
    public DbSet<JournalEntryLine> JournalEntryLines { get; set; } = null!;
    public DbSet<PartyAccount> PartyAccounts { get; set; } = null!;

    public AccountingDbContext(DbContextOptions<AccountingDbContext> options)
        : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.ConfigureAccounting();
    }
}
