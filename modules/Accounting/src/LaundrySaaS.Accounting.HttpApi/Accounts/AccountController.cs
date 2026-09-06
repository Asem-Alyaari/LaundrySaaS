using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.Accounts;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/accounts")]
public class AccountController : AccountingController, IAccountAppService
{
    private readonly IAccountAppService _accountAppService;

    public AccountController(IAccountAppService accountAppService)
    {
        _accountAppService = accountAppService;
    }

    [HttpGet]
    [Route("{id}")]
    public Task<AccountDto> GetAsync(Guid id)
    {
        return _accountAppService.GetAsync(id);
    }

    [HttpGet]
    public Task<PagedResultDto<AccountDto>> GetListAsync(PagedAndSortedResultRequestDto input)
    {
        return _accountAppService.GetListAsync(input);
    }

    [HttpGet]
    [Route("tree")]
    public Task<List<AccountTreeNodeDto>> GetTreeAsync()
    {
        return _accountAppService.GetTreeAsync();
    }

    [HttpGet]
    [Route("leaf-accounts")]
    public Task<List<AccountLookupDto>> GetLeafAccountsAsync()
    {
        return _accountAppService.GetLeafAccountsAsync();
    }

    [HttpPost]
    public Task<AccountDto> CreateAsync(CreateAccountDto input)
    {
        return _accountAppService.CreateAsync(input);
    }

    [HttpPut]
    [Route("{id}")]
    public Task<AccountDto> UpdateAsync(Guid id, UpdateAccountDto input)
    {
        return _accountAppService.UpdateAsync(id, input);
    }

    [HttpDelete]
    [Route("{id}")]
    public Task DeleteAsync(Guid id)
    {
        return _accountAppService.DeleteAsync(id);
    }
}
