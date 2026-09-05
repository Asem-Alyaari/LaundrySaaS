using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Laundries.Items;

public class CreateUpdateServiceItemDto
{
    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public decimal Price { get; set; }

    [Required]
    public Guid CategoryId { get; set; }

    [Required]
    public Guid LaundryId { get; set; }

    public bool IsActive { get; set; } = true;

    [MaxLength(32)]
    public string Unit { get; set; } = "piece";

    public double DurationHours { get; set; } = 0;

    [MaxLength(512)]
    public string? Description { get; set; }

    [MaxLength(128)]
    public string? Icon { get; set; }
}
