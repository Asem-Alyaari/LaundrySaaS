using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts.Dtos;
using LaundrySaaS.Accounting.Permissions;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Accounting.Accounts;

[Authorize(AccountingPermissions.Accounts.Default)]
public class AccountAppService : AccountingAppService, IAccountAppService
{
    private readonly IAccountRepository _accountRepository;
    private readonly AccountManager _accountManager;
    private readonly AccountingApplicationMappers _mapper;

    public AccountAppService(
        IAccountRepository accountRepository,
        AccountManager accountManager,
        AccountingApplicationMappers mapper)
    {
        _accountRepository = accountRepository;
        _accountManager = accountManager;
        _mapper = mapper;
    }

    public async Task<AccountDto> GetAsync(Guid id)
    {
        var account = await _accountRepository.GetAsync(id);
        return _mapper.ToDto(account);
    }

    public async Task<PagedResultDto<AccountDto>> GetListAsync(PagedAndSortedResultRequestDto input)
    {
        var totalCount = await _accountRepository.GetCountAsync();
        var accounts = await _accountRepository.GetPagedListAsync(
            input.SkipCount,
            input.MaxResultCount,
            input.Sorting ?? nameof(Account.Code)
        );

        return new PagedResultDto<AccountDto>(
            totalCount,
            accounts.Select(_mapper.ToDto).ToList()
        );
    }

    public async Task<List<AccountTreeNodeDto>> GetTreeAsync()
    {
        var allAccounts = await _accountRepository.GetListAsync();
        var ordered = allAccounts.OrderBy(a => a.Code).ToList();

        var lookup = ordered.ToDictionary(
            a => a.Id,
            a =>
            {
                var dto = _mapper.ToDto(a);
                return new AccountTreeNodeDto
                {
                    Id = dto.Id,
                    Code = dto.Code,
                    Name = dto.Name,
                    EnglishName = dto.EnglishName,
                    ParentId = dto.ParentId,
                    AccountType = dto.AccountType,
                    NormalBalance = dto.NormalBalance,
                    AllowDirectPosting = dto.AllowDirectPosting,
                    Level = dto.Level,
                    Currency = dto.Currency,
                    IsActive = dto.IsActive,
                    Description = dto.Description,
                    Children = new List<AccountTreeNodeDto>()
                };
            }
        );

        var rootNodes = new List<AccountTreeNodeDto>();

        foreach (var node in lookup.Values)
        {
            if (node.ParentId.HasValue && lookup.TryGetValue(node.ParentId.Value, out var parentNode))
            {
                parentNode.Children.Add(node);
            }
            else
            {
                rootNodes.Add(node);
            }
        }

        return rootNodes;
    }

    public async Task<List<AccountLookupDto>> GetLeafAccountsAsync()
    {
        var leafAccounts = await _accountRepository.GetLeafAccountsAsync();
        return leafAccounts.Select(a => new AccountLookupDto
        {
            Id = a.Id,
            Code = a.Code,
            Name = $"{a.Code} - {a.Name}",
            AccountType = a.AccountType
        }).ToList();
    }

    [Authorize(AccountingPermissions.Accounts.Create)]
    public async Task<AccountDto> CreateAsync(CreateAccountDto input)
    {
        var account = await _accountManager.CreateAsync(
            input.Code,
            input.Name,
            input.AccountType,
            input.NormalBalance,
            input.ParentId,
            input.AllowDirectPosting,
            input.Currency,
            input.EnglishName,
            input.Description
        );

        await _accountRepository.InsertAsync(account);
        return _mapper.ToDto(account);
    }

    [Authorize(AccountingPermissions.Accounts.Update)]
    public async Task<AccountDto> UpdateAsync(Guid id, UpdateAccountDto input)
    {
        var account = await _accountRepository.GetAsync(id);

        account.Update(
            input.Name,
            input.EnglishName,
            input.Description,
            input.AllowDirectPosting,
            input.IsActive
        );

        await _accountRepository.UpdateAsync(account);
        return _mapper.ToDto(account);
    }

    [Authorize(AccountingPermissions.Accounts.Delete)]
    public async Task DeleteAsync(Guid id)
    {
        var account = await _accountRepository.GetAsync(id);
        await _accountManager.ValidateDeletionAsync(account);
        await _accountRepository.DeleteAsync(account);
    }
}
