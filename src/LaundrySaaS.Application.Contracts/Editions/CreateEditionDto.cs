using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Editions;

public class CreateEditionDto
{
    [Required]
    [MaxLength(128)]
    public string DisplayName { get; set; } = string.Empty;

    public decimal Price { get; set; }

    public decimal AnnualPrice { get; set; }

    public PlanType PlanType { get; set; } = PlanType.Standard;

    public bool IsFree { get; set; }
}
