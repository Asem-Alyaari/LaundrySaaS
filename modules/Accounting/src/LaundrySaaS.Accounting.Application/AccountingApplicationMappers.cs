#pragma warning disable RMG020
#pragma warning disable RMG012

using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.Accounts.Dtos;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.CostCenters.Dtos;
using LaundrySaaS.Accounting.FiscalYears;
using LaundrySaaS.Accounting.FiscalYears.Dtos;
using LaundrySaaS.Accounting.JournalEntries;
using LaundrySaaS.Accounting.JournalEntries.Dtos;
using LaundrySaaS.Accounting.Parties;
using LaundrySaaS.Accounting.Parties.Dtos;
using Riok.Mapperly.Abstractions;

namespace LaundrySaaS.Accounting;

[Mapper]
public partial class AccountingApplicationMappers
{
    public partial AccountDto ToDto(Account source);
    public partial CostCenterDto ToDto(CostCenter source);
    public partial FiscalYearDto ToDto(FiscalYear source);
    public partial FiscalPeriodDto ToDto(FiscalPeriod source);
    public partial JournalEntryDto ToDto(JournalEntry source);
    public partial JournalEntryLineDto ToDto(JournalEntryLine source);
    public partial PartyAccountDto ToDto(PartyAccount source);
}
