using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.JournalEntries.Dtos;

public class JournalEntryDto : FullAuditedEntityDto<Guid>
{
    public string EntryNumber { get; set; } = string.Empty;
    public DateTime EntryDate { get; set; }
    public string Description { get; set; } = string.Empty;
    public JournalEntryStatus Status { get; set; }
    public JournalEntryType EntryType { get; set; }
    public string? SourceModule { get; set; }
    public Guid? SourceEntityId { get; set; }
    public decimal TotalDebit { get; set; }
    public decimal TotalCredit { get; set; }
    public DateTime? PostedAt { get; set; }
    public Guid? PostedByUserId { get; set; }
    public string? CancellationReason { get; set; }
    public List<JournalEntryLineDto> Lines { get; set; } = new();
}

public class CreateJournalEntryDto
{
    [Required]
    public DateTime EntryDate { get; set; } = DateTime.UtcNow;

    [Required]
    [StringLength(512)]
    public string Description { get; set; } = string.Empty;

    public JournalEntryType EntryType { get; set; } = JournalEntryType.Manual;

    [StringLength(64)]
    public string? SourceModule { get; set; }

    public Guid? SourceEntityId { get; set; }

    [Required]
    [MinLength(2)]
    public List<CreateJournalEntryLineDto> Lines { get; set; } = new();
}

public class UpdateJournalEntryDto
{
    [Required]
    public DateTime EntryDate { get; set; }

    [Required]
    [StringLength(512)]
    public string Description { get; set; } = string.Empty;

    [Required]
    [MinLength(2)]
    public List<CreateJournalEntryLineDto> Lines { get; set; } = new();
}

public class CancelJournalEntryDto
{
    [Required]
    [StringLength(256)]
    public string Reason { get; set; } = string.Empty;
}

public class GetJournalEntriesInput : PagedAndSortedResultRequestDto
{
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public JournalEntryStatus? Status { get; set; }
    public string? SourceModule { get; set; }
    public Guid? AccountId { get; set; }
}
