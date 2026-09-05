using LaundrySaaS.Editions;
using LaundrySaaS.Subscriptions;
using Riok.Mapperly.Abstractions;
using Volo.Abp.Mapperly;

namespace LaundrySaaS;

[Mapper]
public partial class LaundrySaaSApplicationMappers
{
    public partial EditionDto Map(Edition source);
    public partial TenantSubscriptionDto Map(TenantSubscription source);
}
