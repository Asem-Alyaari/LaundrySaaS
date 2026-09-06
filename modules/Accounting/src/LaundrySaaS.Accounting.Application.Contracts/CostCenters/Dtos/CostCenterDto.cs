using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.CostCenters.Dtos;

public class CostCenterDto : FullAuditedEntityDto<Guid>
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public Guid? ParentId { get; set; }
    public Guid? LaundryId { get; set; }
    public bool IsActive { get; set; }
}

public class CreateCostCenterDto
{
    [Required]
    [StringLength(64)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [StringLength(256)]
    public string Name { get; set; } = string.Empty;

    public Guid? ParentId { get; set; }

    public Guid? LaundryId { get; set; }

    public bool IsActive { get; set; } = true;
}

public class UpdateCostCenterDto
{
    [Required]
    [StringLength(256)]
    public string Name { get; set; } = string.Empty;

    public Guid? ParentId { get; set; }

    public Guid? LaundryId { get; set; }

    public bool IsActive { get; set; }
}
