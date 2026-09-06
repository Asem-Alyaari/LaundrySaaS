using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.FiscalYears;
using LaundrySaaS.Accounting.JournalEntries;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

public static class AccountingDbContextModelCreatingExtensions
{
    public static void ConfigureAccounting(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Account>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "Accounts", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.Code).IsRequired().HasMaxLength(64);
            b.Property(x => x.Name).IsRequired().HasMaxLength(256);
            b.Property(x => x.EnglishName).HasMaxLength(256);
            b.Property(x => x.Currency).IsRequired().HasMaxLength(8);
            b.Property(x => x.Description).HasMaxLength(512);

            b.HasIndex(x => new { x.TenantId, x.Code }).IsUnique();
            b.HasIndex(x => x.ParentId);
            b.HasIndex(x => x.AccountType);
        });

        builder.Entity<FiscalYear>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "FiscalYears", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.Name).IsRequired().HasMaxLength(128);

            b.HasMany(x => x.Periods)
                .WithOne()
                .HasForeignKey(x => x.FiscalYearId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);

            b.HasIndex(x => new { x.TenantId, x.StartDate, x.EndDate });
        });

        builder.Entity<FiscalPeriod>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "FiscalPeriods", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.Name).IsRequired().HasMaxLength(64);

            b.HasIndex(x => new { x.FiscalYearId, x.PeriodNumber }).IsUnique();
        });

        builder.Entity<CostCenter>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "CostCenters", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.Code).IsRequired().HasMaxLength(64);
            b.Property(x => x.Name).IsRequired().HasMaxLength(256);

            b.HasIndex(x => new { x.TenantId, x.Code }).IsUnique();
            b.HasIndex(x => x.LaundryId);
        });

        builder.Entity<JournalEntry>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "JournalEntries", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.EntryNumber).IsRequired().HasMaxLength(64);
            b.Property(x => x.Description).IsRequired().HasMaxLength(512);
            b.Property(x => x.TotalDebit).HasPrecision(18, 4);
            b.Property(x => x.TotalCredit).HasPrecision(18, 4);
            b.Property(x => x.SourceModule).HasMaxLength(64);
            b.Property(x => x.CancellationReason).HasMaxLength(256);

            b.HasMany(x => x.Lines)
                .WithOne()
                .HasForeignKey(x => x.JournalEntryId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);

            b.HasIndex(x => new { x.TenantId, x.EntryNumber }).IsUnique();
            b.HasIndex(x => new { x.TenantId, x.EntryDate });
            b.HasIndex(x => new { x.TenantId, x.Status });
            b.HasIndex(x => new { x.SourceModule, x.SourceEntityId });
        });

        builder.Entity<JournalEntryLine>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "JournalEntryLines", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.Debit).HasPrecision(18, 4);
            b.Property(x => x.Credit).HasPrecision(18, 4);
            b.Property(x => x.Description).HasMaxLength(512);
            b.Property(x => x.Reference).HasMaxLength(128);

            b.HasIndex(x => x.AccountId);
            b.HasIndex(x => x.CostCenterId);
        });

        builder.Entity<LaundrySaaS.Accounting.Parties.PartyAccount>(b =>
        {
            b.ToTable(AccountingDbProperties.DbTablePrefix + "PartyAccounts", AccountingDbProperties.DbSchema);
            b.ConfigureByConvention();

            b.Property(x => x.PartyName).IsRequired().HasMaxLength(256);

            b.HasIndex(x => new { x.TenantId, x.PartyType, x.EntityId }).IsUnique();
            b.HasIndex(x => x.AccountId);
        });
    }
}
