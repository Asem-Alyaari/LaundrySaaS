using System;
using Volo.Abp;
using Volo.Abp.Domain.Entities;

namespace LaundrySaaS.Accounting.JournalEntries;

public class JournalEntryLine : Entity<Guid>
{
    public Guid JournalEntryId { get; private set; }

    public Guid AccountId { get; private set; }

    public decimal Debit { get; private set; }

    public decimal Credit { get; private set; }

    public string? Description { get; private set; }

    public Guid? CostCenterId { get; private set; }

    public string? Reference { get; private set; }

    private JournalEntryLine()
    {

    }

    public JournalEntryLine(
        Guid id,
        Guid journalEntryId,
        Guid accountId,
        decimal debit,
        decimal credit,
        string? description = null,
        Guid? costCenterId = null,
        string? reference = null)
        : base(id)
    {
        JournalEntryId = journalEntryId;
        AccountId = accountId;
        Debit = debit;
        Credit = credit;
        Description = description;
        CostCenterId = costCenterId;
        Reference = reference;
    }
}
