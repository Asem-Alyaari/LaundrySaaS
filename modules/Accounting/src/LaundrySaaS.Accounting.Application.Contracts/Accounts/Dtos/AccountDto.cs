using System;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.Accounts.Dtos;

public class AccountDto : FullAuditedEntityDto<Guid>
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? EnglishName { get; set; }
    public Guid? ParentId { get; set; }
    public AccountType AccountType { get; set; }
    public AccountNormalBalance NormalBalance { get; set; }
    public bool AllowDirectPosting { get; set; }
    public int Level { get; set; }
    public string Currency { get; set; } = "SAR";
    public bool IsActive { get; set; }
    public string? Description { get; set; }
}
