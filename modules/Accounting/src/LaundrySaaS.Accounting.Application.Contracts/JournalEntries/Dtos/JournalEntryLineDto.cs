using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Accounting.JournalEntries.Dtos;

public class JournalEntryLineDto
{
    public Guid Id { get; set; }
    public Guid AccountId { get; set; }
    public string AccountCode { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
    public decimal Debit { get; set; }
    public decimal Credit { get; set; }
    public string? Description { get; set; }
    public Guid? CostCenterId { get; set; }
    public string? CostCenterName { get; set; }
    public string? Reference { get; set; }
}

public class CreateJournalEntryLineDto
{
    [Required]
    public Guid AccountId { get; set; }

    [Range(0, 999999999999.9999)]
    public decimal Debit { get; set; }

    [Range(0, 999999999999.9999)]
    public decimal Credit { get; set; }

    [StringLength(512)]
    public string? Description { get; set; }

    public Guid? CostCenterId { get; set; }

    [StringLength(128)]
    public string? Reference { get; set; }
}
