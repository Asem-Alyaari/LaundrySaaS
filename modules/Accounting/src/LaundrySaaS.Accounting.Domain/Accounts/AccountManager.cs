using System;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Domain.Services;

namespace LaundrySaaS.Accounting.Accounts;

public class AccountManager : DomainService
{
    private readonly IAccountRepository _accountRepository;

    public AccountManager(IAccountRepository accountRepository)
    {
        _accountRepository = accountRepository;
    }

    public async Task<Account> CreateAsync(
        string code,
        string name,
        AccountType accountType,
        AccountNormalBalance normalBalance,
        Guid? parentId = null,
        bool allowDirectPosting = true,
        string currency = "SAR",
        string? englishName = null,
        string? description = null)
    {
        Check.NotNullOrWhiteSpace(code, nameof(code));
        Check.NotNullOrWhiteSpace(name, nameof(name));

        var existing = await _accountRepository.FindByCodeAsync(code);
        if (existing != null)
        {
            throw new BusinessException(AccountingErrorCodes.AccountCodeAlreadyExists)
                .WithData("Code", code);
        }

        int level = 1;
        if (parentId.HasValue)
        {
            var parent = await _accountRepository.GetAsync(parentId.Value);
            level = parent.Level + 1;
        }

        return new Account(
            GuidGenerator.Create(),
            CurrentTenant.Id,
            code,
            name,
            accountType,
            normalBalance,
            parentId,
            level,
            allowDirectPosting,
            currency,
            englishName,
            description
        );
    }

    public async Task ChangeCodeAsync(Account account, string newCode)
    {
        Check.NotNull(account, nameof(account));
        Check.NotNullOrWhiteSpace(newCode, nameof(newCode));

        if (account.Code == newCode)
        {
            return;
        }

        var existing = await _accountRepository.FindByCodeAsync(newCode);
        if (existing != null && existing.Id != account.Id)
        {
            throw new BusinessException(AccountingErrorCodes.AccountCodeAlreadyExists)
                .WithData("Code", newCode);
        }

        account.SetCode(newCode);
    }

    public async Task ValidateDeletionAsync(Account account)
    {
        var hasChildren = await _accountRepository.HasChildrenAsync(account.Id);
        if (hasChildren)
        {
            throw new BusinessException(AccountingErrorCodes.CannotDeleteAccountWithEntries)
                .WithData("Account", account.Name);
        }

        var hasTransactions = await _accountRepository.HasTransactionsAsync(account.Id);
        if (hasTransactions)
        {
            throw new BusinessException(AccountingErrorCodes.CannotDeleteAccountWithEntries)
                .WithData("Account", account.Name);
        }
    }
}
