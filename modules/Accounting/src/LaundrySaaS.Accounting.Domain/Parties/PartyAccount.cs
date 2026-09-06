using System;
using Volo.Abp;
using Volo.Abp.Domain.Entities.Auditing;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.Parties;

public class PartyAccount : FullAuditedAggregateRoot<Guid>, IMultiTenant
{
    public Guid? TenantId { get; set; }

    /// <summary>
    /// Type of party: Customer, Driver, Laundry, Vendor
    /// </summary>
    public PartyType PartyType { get; private set; }

    /// <summary>
    /// External entity ID (e.g., CustomerId, DriverId, LaundryId)
    /// </summary>
    public Guid EntityId { get; private set; }

    /// <summary>
    /// Linked financial Account ID in chart of accounts
    /// </summary>
    public Guid AccountId { get; private set; }

    /// <summary>
    /// Name of the party for display
    /// </summary>
    public string PartyName { get; private set; }

    private PartyAccount()
    {
        PartyName = string.Empty;
    }

    public PartyAccount(
        Guid id,
        Guid? tenantId,
        PartyType partyType,
        Guid entityId,
        Guid accountId,
        string partyName)
        : base(id)
    {
        TenantId = tenantId;
        PartyType = partyType;
        EntityId = entityId;
        AccountId = accountId;
        PartyName = Check.NotNullOrWhiteSpace(partyName, nameof(partyName), maxLength: 256);
    }

    public void UpdateName(string partyName)
    {
        PartyName = Check.NotNullOrWhiteSpace(partyName, nameof(partyName), maxLength: 256);
    }
}
