using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Orders.Orders;

public class RecordOrderPaymentDto
{
    [Range(0.01, double.MaxValue, ErrorMessage = "المبلغ المدفوع يجب أن يكون أكبر من صفر")]
    public decimal Amount { get; set; }

    public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.Cash;

    public bool MarkAsDelivered { get; set; } = false;
}
