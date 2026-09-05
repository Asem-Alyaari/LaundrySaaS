using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Editions;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Subscriptions;

public class TenantSubscriptionAppService : ApplicationService, ITenantSubscriptionAppService
{
    private readonly IRepository<TenantSubscription, Guid> _subscriptionRepository;
    private readonly IRepository<Edition, Guid> _editionRepository;

    public TenantSubscriptionAppService(
        IRepository<TenantSubscription, Guid> subscriptionRepository,
        IRepository<Edition, Guid> editionRepository)
    {
        _subscriptionRepository = subscriptionRepository;
        _editionRepository = editionRepository;
    }

    public async Task<TenantSubscriptionDto?> GetByTenantIdAsync(Guid tenantId)
    {
        var query = await _subscriptionRepository.WithDetailsAsync(s => s.Edition);
        var subscription = await AsyncExecuter.FirstOrDefaultAsync(query.Where(s => s.TenantId == tenantId));

        if (subscription == null)
        {
            return null;
        }

        return MapToDto(subscription);
    }

    public async Task<List<TenantSubscriptionDto>> GetAllSubscriptionsAsync()
    {
        var query = await _subscriptionRepository.WithDetailsAsync(s => s.Edition);
        var subscriptions = await AsyncExecuter.ToListAsync(query);

        return subscriptions.Select(s => MapToDto(s, null)).ToList();
    }

    public async Task<TenantSubscriptionDto> AssignOrUpdateSubscriptionAsync(AssignTenantSubscriptionDto input)
    {
        var edition = await _editionRepository.GetAsync(input.EditionId);

        var query = await _subscriptionRepository.GetQueryableAsync();
        var existing = await AsyncExecuter.FirstOrDefaultAsync(query.Where(s => s.TenantId == input.TenantId));

        var startDate = DateTime.UtcNow;
        var expireDate = input.SubscriptionCycle == SubscriptionCycle.Annual
            ? startDate.AddYears(1)
            : startDate.AddMonths(1);

        if (existing != null)
        {
            existing.Update(
                input.EditionId,
                input.SubscriptionCycle,
                startDate,
                expireDate,
                SubscriptionStatus.Active
            );
            await _subscriptionRepository.UpdateAsync(existing);
            return MapToDto(existing, edition);
        }

        var newSubscription = new TenantSubscription(
            GuidGenerator.Create(),
            input.TenantId,
            input.EditionId,
            input.SubscriptionCycle,
            startDate,
            expireDate,
            SubscriptionStatus.Active
        );

        await _subscriptionRepository.InsertAsync(newSubscription);
        return MapToDto(newSubscription, edition);
    }

    private TenantSubscriptionDto MapToDto(TenantSubscription subscription, Edition? edition = null)
    {
        var ed = edition ?? subscription.Edition;
        return new TenantSubscriptionDto
        {
            Id = subscription.Id,
            TenantId = subscription.TenantId,
            EditionId = subscription.EditionId,
            EditionName = ed?.DisplayName,
            SubscriptionCycle = subscription.SubscriptionCycle,
            StartDate = subscription.StartDate,
            ExpireDate = subscription.ExpireDate,
            Status = subscription.Status,
            Edition = ed != null
                ? new EditionDto
                {
                    Id = ed.Id,
                    DisplayName = ed.DisplayName,
                    Price = ed.Price,
                    AnnualPrice = ed.AnnualPrice,
                    PlanType = ed.PlanType,
                    IsFree = ed.IsFree
                }
                : null
        };
    }
}
