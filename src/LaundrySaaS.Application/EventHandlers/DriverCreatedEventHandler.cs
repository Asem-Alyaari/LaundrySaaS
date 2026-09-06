using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties;
using LaundrySaaS.Drivers.Drivers;
using Microsoft.Extensions.Logging;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Entities.Events;
using Volo.Abp.EventBus;
using Volo.Abp.Uow;

namespace LaundrySaaS.EventHandlers;

public class DriverCreatedEventHandler : ILocalEventHandler<EntityCreatedEventData<Driver>>, ITransientDependency
{
    private readonly PartyAccountManager _partyAccountManager;
    private readonly ILogger<DriverCreatedEventHandler> _logger;

    public DriverCreatedEventHandler(
        PartyAccountManager partyAccountManager,
        ILogger<DriverCreatedEventHandler> logger)
    {
        _partyAccountManager = partyAccountManager;
        _logger = logger;
    }

    [UnitOfWork]
    public virtual async Task HandleEventAsync(EntityCreatedEventData<Driver> eventData)
    {
        var driver = eventData.Entity;
        _logger.LogInformation("Creating financial account for new Driver: {DriverName} (Id: {DriverId})", driver.FullName, driver.Id);

        await _partyAccountManager.GetOrCreateAccountAsync(
            PartyType.Driver,
            driver.Id,
            driver.FullName,
            driver.TenantId
        );
    }
}
