using System;
using Volo.Abp;
using Volo.Abp.Domain.Entities;

namespace LaundrySaaS.Accounting.FiscalYears;

public class FiscalPeriod : Entity<Guid>
{
    public Guid FiscalYearId { get; private set; }

    public int PeriodNumber { get; private set; }

    public string Name { get; private set; }

    public DateTime StartDate { get; private set; }

    public DateTime EndDate { get; private set; }

    public bool IsClosed { get; private set; }

    private FiscalPeriod()
    {
        Name = string.Empty;
    }

    public FiscalPeriod(
        Guid id,
        Guid fiscalYearId,
        int periodNumber,
        string name,
        DateTime startDate,
        DateTime endDate,
        bool isClosed = false)
        : base(id)
    {
        FiscalYearId = fiscalYearId;
        PeriodNumber = periodNumber;
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 64);
        StartDate = startDate;
        EndDate = endDate;
        IsClosed = isClosed;
    }

    public void Close()
    {
        IsClosed = true;
    }

    public void Reopen()
    {
        IsClosed = false;
    }
}
