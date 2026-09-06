using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using Volo.Abp;
using Volo.Abp.Domain.Services;

namespace LaundrySaaS.Accounting.Parties;

public class PartyAccountManager : DomainService
{
    private readonly IPartyAccountRepository _partyAccountRepository;
    private readonly IAccountRepository _accountRepository;
    private readonly AccountManager _accountManager;
    private readonly ICostCenterRepository _costCenterRepository;

    public PartyAccountManager(
        IPartyAccountRepository partyAccountRepository,
        IAccountRepository accountRepository,
        AccountManager accountManager,
        ICostCenterRepository costCenterRepository)
    {
        _partyAccountRepository = partyAccountRepository;
        _accountRepository = accountRepository;
        _accountManager = accountManager;
        _costCenterRepository = costCenterRepository;
    }

    public async Task<Account> GetOrCreateAccountAsync(
        PartyType partyType,
        Guid entityId,
        string partyName,
        Guid? tenantId = null)
    {
        Check.NotNullOrWhiteSpace(partyName, nameof(partyName));

        // 1. Check if mapping already exists
        var existingParty = await _partyAccountRepository.FindByPartyAsync(partyType, entityId);
        if (existingParty != null)
        {
            var existingAccount = await _accountRepository.FindAsync(existingParty.AccountId);
            if (existingAccount != null)
            {
                return existingAccount;
            }
        }

        // 2. Determine parent account code and properties
        string parentCode;
        AccountType accountType;
        AccountNormalBalance normalBalance;

        switch (partyType)
        {
            case PartyType.Customer:
                parentCode = "1103"; // ذمم العملاء
                accountType = AccountType.Asset;
                normalBalance = AccountNormalBalance.Debit;
                break;
            case PartyType.Driver:
                parentCode = "1105"; // عهد ونقدية المناديب
                accountType = AccountType.Asset;
                normalBalance = AccountNormalBalance.Debit;
                break;
            case PartyType.Vendor:
                parentCode = "2101"; // ذمم الموردين
                accountType = AccountType.Liability;
                normalBalance = AccountNormalBalance.Credit;
                break;
            case PartyType.Laundry:
            default:
                parentCode = "1103";
                accountType = AccountType.Asset;
                normalBalance = AccountNormalBalance.Debit;
                break;
        }

        var parentAccount = await _accountRepository.FindByCodeAsync(parentCode);
        Guid? parentId = parentAccount?.Id;

        // 3. Generate sequential sub-account code
        int nextIndex = 1;
        if (parentId.HasValue)
        {
            var children = await _accountRepository.GetChildrenAsync(parentId.Value);
            nextIndex = children.Count + 1;
        }
        else
        {
            nextIndex = (int)(await _accountRepository.GetCountAsync()) + 1;
        }

        string newCode = $"{parentCode}{nextIndex:D4}";

        // Ensure code is unique in case of gaps
        while (await _accountRepository.FindByCodeAsync(newCode) != null)
        {
            nextIndex++;
            newCode = $"{parentCode}{nextIndex:D4}";
        }

        // 4. Create Sub-Account
        string prefix = partyType switch
        {
            PartyType.Customer => "عميل",
            PartyType.Driver => "مندوب",
            PartyType.Vendor => "مورد",
            PartyType.Laundry => "مغسلة",
            _ => "جهة"
        };

        var account = await _accountManager.CreateAsync(
            newCode,
            $"{prefix}: {partyName}",
            accountType,
            normalBalance,
            parentId: parentId,
            allowDirectPosting: true,
            currency: "SAR",
            englishName: $"{partyType}: {partyName}"
        );

        await _accountRepository.InsertAsync(account, autoSave: true);

        // 5. Create PartyAccount mapping
        var partyAccount = new PartyAccount(
            GuidGenerator.Create(),
            tenantId ?? CurrentTenant.Id,
            partyType,
            entityId,
            account.Id,
            partyName
        );

        await _partyAccountRepository.InsertAsync(partyAccount, autoSave: true);

        // 6. If Laundry, create or link a Cost Center as well
        if (partyType == PartyType.Laundry)
        {
            var existingCostCenter = await _costCenterRepository.FindByCodeAsync($"CC-LND-{entityId.ToString()[..4]}");
            if (existingCostCenter == null)
            {
                var costCenter = new CostCenter(
                    GuidGenerator.Create(),
                    tenantId ?? CurrentTenant.Id,
                    $"CC-LND-{nextIndex:D3}",
                    $"فرع: {partyName}",
                    laundryId: entityId
                );
                await _costCenterRepository.InsertAsync(costCenter, autoSave: true);
            }
        }

        return account;
    }
}
