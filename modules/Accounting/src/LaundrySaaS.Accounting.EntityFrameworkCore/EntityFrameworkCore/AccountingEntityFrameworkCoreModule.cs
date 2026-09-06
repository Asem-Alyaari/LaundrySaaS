using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.FiscalYears;
using LaundrySaaS.Accounting.JournalEntries;
using LaundrySaaS.Accounting.Parties;
using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Accounting.EntityFrameworkCore;

[DependsOn(
    typeof(AccountingDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class AccountingEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<AccountingDbContext>(options =>
        {
            options.AddRepository<Account, EfCoreAccountRepository>();
            options.AddRepository<JournalEntry, EfCoreJournalEntryRepository>();
            options.AddRepository<FiscalYear, EfCoreFiscalYearRepository>();
            options.AddRepository<CostCenter, EfCoreCostCenterRepository>();
            options.AddRepository<PartyAccount, EfCorePartyAccountRepository>();
        });
    }
}
