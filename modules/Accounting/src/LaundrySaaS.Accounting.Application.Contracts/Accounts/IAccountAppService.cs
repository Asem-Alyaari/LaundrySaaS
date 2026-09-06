using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts.Dtos;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.Accounts;

public interface IAccountAppService : IApplicationService
{
    Task<AccountDto> GetAsync(Guid id);

    Task<PagedResultDto<AccountDto>> GetListAsync(PagedAndSortedResultRequestDto input);

    Task<List<AccountTreeNodeDto>> GetTreeAsync();

    Task<List<AccountLookupDto>> GetLeafAccountsAsync();

    Task<AccountDto> CreateAsync(CreateAccountDto input);

    Task<AccountDto> UpdateAsync(Guid id, UpdateAccountDto input);

    Task DeleteAsync(Guid id);
}
