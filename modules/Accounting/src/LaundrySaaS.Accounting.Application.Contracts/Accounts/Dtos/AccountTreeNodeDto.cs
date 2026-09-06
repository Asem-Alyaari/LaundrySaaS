using System.Collections.Generic;

namespace LaundrySaaS.Accounting.Accounts.Dtos;

public class AccountTreeNodeDto : AccountDto
{
    public List<AccountTreeNodeDto> Children { get; set; } = new();
}
