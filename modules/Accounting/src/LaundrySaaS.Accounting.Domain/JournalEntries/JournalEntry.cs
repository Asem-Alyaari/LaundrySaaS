using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using LaundrySaaS.Accounting.JournalEntries;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.JournalEntries;

public class JournalEntry : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }

    /// <summary>
    /// Sequential unique entry number (e.g. JE-2026-000001)
    /// </summary>
    public string EntryNumber { get; private set; }

    /// <summary>
    /// Financial entry date
    /// </summary>
    public DateTime EntryDate { get; private set; }

    /// <summary>
    /// General description / narrative for the journal entry
    /// </summary>
    public string Description { get; private set; }

    /// <summary>
    /// Draft = 0, Posted = 1, Cancelled = 2
    /// </summary>
    public JournalEntryStatus Status { get; private set; }

    /// <summary>
    /// Manual, Automatic, Closing, Adjusting
    /// </summary>
    public JournalEntryType EntryType { get; private set; }

    /// <summary>
    /// Integration source module name (e.g., "Orders", "Billing", "Payroll")
    /// </summary>
    public string? SourceModule { get; private set; }

    /// <summary>
    /// Integration source entity ID (e.g., OrderId)
    /// </summary>
    public Guid? SourceEntityId { get; private set; }

    /// <summary>
    /// Sum of all debit amounts in lines
    /// </summary>
    public decimal TotalDebit { get; private set; }

    /// <summary>
    /// Sum of all credit amounts in lines
    /// </summary>
    public decimal TotalCredit { get; private set; }

    /// <summary>
    /// Timestamp when posted
    /// </summary>
    public DateTime? PostedAt { get; private set; }

    /// <summary>
    /// User who posted this entry
    /// </summary>
    public Guid? PostedByUserId { get; private set; }

    /// <summary>
    /// Cancellation reason if cancelled
    /// </summary>
    public string? CancellationReason { get; private set; }

    private readonly List<JournalEntryLine> _lines;
    public IReadOnlyCollection<JournalEntryLine> Lines => new ReadOnlyCollection<JournalEntryLine>(_lines);

    private JournalEntry()
    {
        EntryNumber = string.Empty;
        Description = string.Empty;
        _lines = new List<JournalEntryLine>();
    }

    public JournalEntry(
        Guid id,
        Guid? tenantId,
        string entryNumber,
        DateTime entryDate,
        string description,
        JournalEntryType entryType = JournalEntryType.Manual,
        string? sourceModule = null,
        Guid? sourceEntityId = null)
        : base(id)
    {
        TenantId = tenantId;
        EntryNumber = Check.NotNullOrWhiteSpace(entryNumber, nameof(entryNumber), maxLength: 64);
        EntryDate = entryDate;
        Description = Check.NotNullOrWhiteSpace(description, nameof(description), maxLength: 512);
        Status = JournalEntryStatus.Draft;
        EntryType = entryType;
        SourceModule = sourceModule;
        SourceEntityId = sourceEntityId;
        _lines = new List<JournalEntryLine>();
    }

    public JournalEntryLine AddLine(
        Guid accountId,
        decimal debit,
        decimal credit,
        string? description = null,
        Guid? costCenterId = null,
        string? reference = null)
    {
        EnsureIsDraft();

        if (debit < 0 || credit < 0 || (debit == 0 && credit == 0))
        {
            throw new BusinessException(AccountingErrorCodes.InvalidAmount);
        }

        var line = new JournalEntryLine(
            Guid.NewGuid(),
            Id,
            accountId,
            debit,
            credit,
            description ?? Description,
            costCenterId,
            reference
        );

        _lines.Add(line);
        RecalculateTotals();
        return line;
    }

    public void RemoveLine(Guid lineId)
    {
        EnsureIsDraft();
        var line = _lines.FirstOrDefault(l => l.Id == lineId);
        if (line != null)
        {
            _lines.Remove(line);
            RecalculateTotals();
        }
    }

    public void ClearLines()
    {
        EnsureIsDraft();
        _lines.Clear();
        RecalculateTotals();
    }

    public void UpdateDetails(DateTime entryDate, string description)
    {
        EnsureIsDraft();
        EntryDate = entryDate;
        Description = Check.NotNullOrWhiteSpace(description, nameof(description), maxLength: 512);
    }

    public void Post(Guid userId, DateTime postedAt)
    {
        EnsureIsDraft();

        if (_lines.Count < 2)
        {
            throw new BusinessException(AccountingErrorCodes.JournalEntryMustHaveAtLeastTwoLines);
        }

        RecalculateTotals();

        if (TotalDebit != TotalCredit || TotalDebit == 0)
        {
            throw new BusinessException(AccountingErrorCodes.JournalEntryNotBalanced)
                .WithData("Debit", TotalDebit)
                .WithData("Credit", TotalCredit);
        }

        Status = JournalEntryStatus.Posted;
        PostedByUserId = userId;
        PostedAt = postedAt;
    }

    public void Cancel(string reason)
    {
        if (Status == JournalEntryStatus.Cancelled)
        {
            return;
        }

        Status = JournalEntryStatus.Cancelled;
        CancellationReason = Check.NotNullOrWhiteSpace(reason, nameof(reason), maxLength: 256);
    }

    private void EnsureIsDraft()
    {
        if (Status != JournalEntryStatus.Draft)
        {
            throw new BusinessException(AccountingErrorCodes.JournalEntryAlreadyPosted);
        }
    }

    private void RecalculateTotals()
    {
        TotalDebit = _lines.Sum(l => l.Debit);
        TotalCredit = _lines.Sum(l => l.Credit);
    }
}
