using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.FiscalYears;

public class FiscalYear : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }

    public string Name { get; private set; }

    public DateTime StartDate { get; private set; }

    public DateTime EndDate { get; private set; }

    public bool IsClosed { get; private set; }

    private readonly List<FiscalPeriod> _periods;
    public IReadOnlyCollection<FiscalPeriod> Periods => new ReadOnlyCollection<FiscalPeriod>(_periods);

    private FiscalYear()
    {
        Name = string.Empty;
        _periods = new List<FiscalPeriod>();
    }

    public FiscalYear(
        Guid id,
        Guid? tenantId,
        string name,
        DateTime startDate,
        DateTime endDate)
        : base(id)
    {
        TenantId = tenantId;
        Name = Check.NotNullOrWhiteSpace(name, nameof(name), maxLength: 128);
        StartDate = startDate;
        EndDate = endDate;
        IsClosed = false;
        _periods = new List<FiscalPeriod>();

        GenerateMonthlyPeriods();
    }

    public void Close()
    {
        IsClosed = true;
        foreach (var period in _periods)
        {
            period.Close();
        }
    }

    public void Reopen()
    {
        IsClosed = false;
    }

    public void ClosePeriod(int periodNumber)
    {
        var period = _periods.FirstOrDefault(p => p.PeriodNumber == periodNumber);
        if (period != null)
        {
            period.Close();
        }
    }

    public void ReopenPeriod(int periodNumber)
    {
        if (IsClosed)
        {
            throw new BusinessException(AccountingErrorCodes.FiscalYearClosed);
        }

        var period = _periods.FirstOrDefault(p => p.PeriodNumber == periodNumber);
        if (period != null)
        {
            period.Reopen();
        }
    }

    public bool IsDateInOpenPeriod(DateTime date)
    {
        if (IsClosed)
        {
            return false;
        }

        var period = _periods.FirstOrDefault(p => date >= p.StartDate && date <= p.EndDate);
        return period != null && !period.IsClosed;
    }

    private void GenerateMonthlyPeriods()
    {
        _periods.Clear();
        var current = StartDate;
        int periodNumber = 1;

        while (current < EndDate && periodNumber <= 12)
        {
            var nextMonth = current.AddMonths(1);
            var periodEnd = nextMonth.AddDays(-1);
            if (periodEnd > EndDate)
            {
                periodEnd = EndDate;
            }

            _periods.Add(new FiscalPeriod(
                Guid.NewGuid(),
                Id,
                periodNumber,
                $"Period {periodNumber:D2}",
                current,
                periodEnd
            ));

            current = nextMonth;
            periodNumber++;
        }
    }
}
