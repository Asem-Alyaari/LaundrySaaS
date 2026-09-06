using System;
using LaundrySaaS.Accounting.Accounts;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.Accounts;

public class Account : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }

    /// <summary>
    /// Account code in chart of accounts (e.g., 1, 11, 1101, 4101)
    /// </summary>
    public string Code { get; private set; }

    /// <summary>
    /// Account Arabic / primary name
    /// </summary>
    public string Name { get; private set; }

    /// <summary>
    /// Optional English or alternate name
    /// </summary>
    public string? EnglishName { get; private set; }

    /// <summary>
    /// Parent account in the chart hierarchy (null for root accounts)
    /// </summary>
    public Guid? ParentId { get; private set; }

    /// <summary>
    /// Major category: Asset, Liability, Equity, Revenue, Expense
    /// </summary>
    public AccountType AccountType { get; private set; }

    /// <summary>
    /// Normal balance: Debit or Credit
    /// </summary>
    public AccountNormalBalance NormalBalance { get; private set; }

    /// <summary>
    /// Only leaf accounts (sub-accounts) allow direct journal postings
    /// </summary>
    public bool AllowDirectPosting { get; private set; }

    /// <summary>
    /// Hierarchy depth level in tree (1 for root, 2 for group, 3 for ledger, etc.)
    /// </summary>
    public int Level { get; private set; }

    /// <summary>
    /// Currency code (e.g. SAR)
    /// </summary>
    public string Currency { get; private set; }

    /// <summary>
    /// Active status
    /// </summary>
    public bool IsActive { get; private set; }

    /// <summary>
    /// Notes or description
    /// </summary>
    public string? Description { get; private set; }

    private Account()
    {
        Code = string.Empty;
        Name = string.Empty;
        Currency = "SAR";
        IsActive = true;
    }

    public Account(
        Guid id,
        Guid? tenantId,
        string code,
        string name,
        AccountType accountType,
        AccountNormalBalance normalBalance,
        Guid? parentId = null,
        int level = 1,
        bool allowDirectPosting = true,
        string currency = "SAR",
        string? englishName = null,
        string? description = null,
        bool isActive = true)
        : base(id)
    {
        TenantId = tenantId;
        Code = Check.NotNullOrWhiteSpace(code, nameof(code), maxLength: 64);
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 256);
        AccountType = accountType;
        NormalBalance = normalBalance;
        ParentId = parentId;
        Level = level;
        AllowDirectPosting = allowDirectPosting;
        Currency = currency;
        EnglishName = englishName;
        Description = description;
        IsActive = isActive;
    }

    public void Update(
        string name,
        string? englishName,
        string? description,
        bool allowDirectPosting,
        bool isActive)
    {
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 256);
        EnglishName = englishName;
        Description = description;
        AllowDirectPosting = allowDirectPosting;
        IsActive = isActive;
    }

    public void SetParent(Guid? parentId, int level)
    {
        ParentId = parentId;
        Level = level;
    }

    public void SetCode(string code)
    {
        Code = Check.NotNullOrWhiteSpace(code, nameof(code), maxLength: 64);
    }
}
