using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Accounting.Accounts.Dtos;

public class CreateAccountDto
{
    [Required]
    [StringLength(64)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [StringLength(256)]
    public string Name { get; set; } = string.Empty;

    [StringLength(256)]
    public string? EnglishName { get; set; }

    public Guid? ParentId { get; set; }

    [Required]
    public AccountType AccountType { get; set; }

    [Required]
    public AccountNormalBalance NormalBalance { get; set; }

    public bool AllowDirectPosting { get; set; } = true;

    [StringLength(8)]
    public string Currency { get; set; } = "SAR";

    [StringLength(512)]
    public string? Description { get; set; }
}

public class UpdateAccountDto
{
    [Required]
    [StringLength(256)]
    public string Name { get; set; } = string.Empty;

    [StringLength(256)]
    public string? EnglishName { get; set; }

    [StringLength(512)]
    public string? Description { get; set; }

    public bool AllowDirectPosting { get; set; }

    public bool IsActive { get; set; }
}

public class AccountLookupDto
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public AccountType AccountType { get; set; }
}
