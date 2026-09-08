using System;
using System.Collections.Generic;

namespace LaundrySaaS.Orders.Orders;

public class GetLaundryReportInputDto
{
    public Guid LaundryId { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}

public class LaundryReportDto
{
    public ReportSummaryDto Summary { get; set; } = new();
    public PaymentBreakdownDto PaymentBreakdown { get; set; } = new();
    public OrderStatusBreakdownDto StatusBreakdown { get; set; } = new();
    public List<TopServiceItemDto> TopServices { get; set; } = new();
    public List<OutstandingDebtDto> OutstandingDebts { get; set; } = new();
}

public class ReportSummaryDto
{
    public int TotalOrdersCount { get; set; }
    public int TotalItemsCount { get; set; }
    public decimal TotalSales { get; set; }
    public decimal TotalPaid { get; set; }
    public decimal TotalRemaining { get; set; }
    public decimal TotalDiscount { get; set; }
    public decimal TotalTax { get; set; }
}

public class PaymentBreakdownDto
{
    public decimal CashAmount { get; set; }
    public decimal CardAmount { get; set; }
    public decimal TransferAmount { get; set; }
    public decimal LaterAmount { get; set; }
}

public class OrderStatusBreakdownDto
{
    public int PendingCount { get; set; }
    public int ProcessingCount { get; set; }
    public int ReadyCount { get; set; }
    public int DeliveredCount { get; set; }
    public int CancelledCount { get; set; }
}

public class TopServiceItemDto
{
    public string ServiceName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal TotalAmount { get; set; }
    public double Percentage { get; set; }
}

public class OutstandingDebtDto
{
    public Guid OrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public string CustomerName { get; set; } = string.Empty;
    public string? CustomerPhoneNumber { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public decimal RemainingAmount { get; set; }
    public DateTime CreationTime { get; set; }
    public int DaysPending { get; set; }
}
