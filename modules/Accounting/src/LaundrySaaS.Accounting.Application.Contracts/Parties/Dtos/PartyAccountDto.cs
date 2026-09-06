using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.Parties.Dtos;

public class PartyAccountDto : FullAuditedEntityDto<Guid>
{
    public PartyType PartyType { get; set; }
    public Guid EntityId { get; set; }
    public Guid AccountId { get; set; }
    public string AccountCode { get; set; } = string.Empty;
    public string PartyName { get; set; } = string.Empty;
}

public class GetOrCreatePartyAccountInput
{
    [Required]
    public PartyType PartyType { get; set; }

    [Required]
    public Guid EntityId { get; set; }

    [Required]
    [StringLength(256)]
    public string PartyName { get; set; } = string.Empty;

    public Guid? TenantId { get; set; }
}
