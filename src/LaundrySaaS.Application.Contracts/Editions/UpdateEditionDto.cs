using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Editions;

public class UpdateEditionDto
{
    [Required]
    [MaxLength(128)]
    public string DisplayName { get; set; } = string.Empty;

    public decimal Price { get; set; }

    public decimal AnnualPrice { get; set; }

    public PlanType PlanType { get; set; }

    public bool IsFree { get; set; }
}
