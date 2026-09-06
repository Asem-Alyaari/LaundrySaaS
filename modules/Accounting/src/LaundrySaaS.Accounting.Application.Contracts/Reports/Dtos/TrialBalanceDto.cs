using System;
using System.Collections.Generic;
using LaundrySaaS.Accounting.Accounts;

namespace LaundrySaaS.Accounting.Reports.Dtos;

public class TrialBalanceItemDto
{
    public Guid AccountId { get; set; }
    public string AccountCode { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
    public AccountType AccountType { get; set; }
    public decimal OpeningDebit { get; set; }
    public decimal OpeningCredit { get; set; }
    public decimal PeriodDebit { get; set; }
    public decimal PeriodCredit { get; set; }
    public decimal EndingDebit { get; set; }
    public decimal EndingCredit { get; set; }
}

public class TrialBalanceDto
{
    public DateTime? AsOfDate { get; set; }
    public List<TrialBalanceItemDto> Items { get; set; } = new();
    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public bool IsBalanced => Math.Abs(TotalDebit - TotalCredit) < 0.0001m;
}
