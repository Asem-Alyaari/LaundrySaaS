using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;

namespace LaundrySaaS.Subscriptions;

[RemoteService(Name = "Saas")]
[Area("saas")]
[Route("api/saas/tenant-subscriptions")]
public class TenantSubscriptionController : LaundrySaaSController, ITenantSubscriptionAppService
{
    private readonly ITenantSubscriptionAppService _tenantSubscriptionAppService;

    public TenantSubscriptionController(ITenantSubscriptionAppService tenantSubscriptionAppService)
    {
        _tenantSubscriptionAppService = tenantSubscriptionAppService;
    }

    [HttpGet("by-tenant/{tenantId}")]
    public Task<TenantSubscriptionDto?> GetByTenantIdAsync(Guid tenantId)
    {
        return _tenantSubscriptionAppService.GetByTenantIdAsync(tenantId);
    }

    [HttpGet]
    public Task<List<TenantSubscriptionDto>> GetAllSubscriptionsAsync()
    {
        return _tenantSubscriptionAppService.GetAllSubscriptionsAsync();
    }

    [HttpPost("assign")]
    public Task<TenantSubscriptionDto> AssignOrUpdateSubscriptionAsync([FromBody] AssignTenantSubscriptionDto input)
    {
        return _tenantSubscriptionAppService.AssignOrUpdateSubscriptionAsync(input);
    }
}
