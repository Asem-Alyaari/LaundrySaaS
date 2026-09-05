using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Subscriptions;

public interface ITenantSubscriptionAppService : IApplicationService
{
    Task<TenantSubscriptionDto?> GetByTenantIdAsync(Guid tenantId);
    Task<List<TenantSubscriptionDto>> GetAllSubscriptionsAsync();
    Task<TenantSubscriptionDto> AssignOrUpdateSubscriptionAsync(AssignTenantSubscriptionDto input);
}
