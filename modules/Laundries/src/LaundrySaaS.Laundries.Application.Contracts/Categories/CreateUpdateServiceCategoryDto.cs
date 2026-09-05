using System;
using System.ComponentModel.DataAnnotations;

namespace LaundrySaaS.Laundries.Categories;

public class CreateUpdateServiceCategoryDto
{
    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;

    public Guid? LaundryId { get; set; }

    [MaxLength(128)]
    public string? Icon { get; set; }

    [MaxLength(32)]
    public string? Color { get; set; }

    public int DisplayOrder { get; set; } = 0;
}
