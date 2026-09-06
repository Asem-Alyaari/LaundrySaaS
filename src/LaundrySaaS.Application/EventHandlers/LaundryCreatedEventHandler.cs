using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties;
using LaundrySaaS.Laundries.Laundries;
using Microsoft.Extensions.Logging;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Entities.Events;
using Volo.Abp.EventBus;
using Volo.Abp.Uow;

namespace LaundrySaaS.EventHandlers;

public class LaundryCreatedEventHandler : ILocalEventHandler<EntityCreatedEventData<Laundry>>, ITransientDependency
{
    private readonly PartyAccountManager _partyAccountManager;
    private readonly ILogger<LaundryCreatedEventHandler> _logger;

    public LaundryCreatedEventHandler(
        PartyAccountManager partyAccountManager,
        ILogger<LaundryCreatedEventHandler> logger)
    {
        _partyAccountManager = partyAccountManager;
        _logger = logger;
    }

    [UnitOfWork]
    public virtual async Task HandleEventAsync(EntityCreatedEventData<Laundry> eventData)
    {
        var laundry = eventData.Entity;
        _logger.LogInformation("Creating financial account and cost center for new Laundry: {LaundryName} (Id: {LaundryId})", laundry.Name, laundry.Id);

        await _partyAccountManager.GetOrCreateAccountAsync(
            PartyType.Laundry,
            laundry.Id,
            laundry.Name,
            laundry.TenantId
        );
    }
}
