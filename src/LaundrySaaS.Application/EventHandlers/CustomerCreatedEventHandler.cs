using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties;
using LaundrySaaS.Customers.Customers;
using Microsoft.Extensions.Logging;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Entities.Events;
using Volo.Abp.EventBus;
using Volo.Abp.Uow;

namespace LaundrySaaS.EventHandlers;

public class CustomerCreatedEventHandler : ILocalEventHandler<EntityCreatedEventData<Customer>>, ITransientDependency
{
    private readonly PartyAccountManager _partyAccountManager;
    private readonly ILogger<CustomerCreatedEventHandler> _logger;

    public CustomerCreatedEventHandler(
        PartyAccountManager partyAccountManager,
        ILogger<CustomerCreatedEventHandler> logger)
    {
        _partyAccountManager = partyAccountManager;
        _logger = logger;
    }

    [UnitOfWork]
    public virtual async Task HandleEventAsync(EntityCreatedEventData<Customer> eventData)
    {
        var customer = eventData.Entity;
        _logger.LogInformation("Creating financial account for new Customer: {CustomerName} (Id: {CustomerId})", customer.FullName, customer.Id);

        await _partyAccountManager.GetOrCreateAccountAsync(
            PartyType.Customer,
            customer.Id,
            customer.FullName
        );
    }
}
