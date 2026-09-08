using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.Data;
using LaundrySaaS.Accounting.JournalEntries;
using LaundrySaaS.Accounting.Parties;
using LaundrySaaS.Orders.Orders;
using Microsoft.Extensions.Logging;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;
using Volo.Abp.Guids;
using Volo.Abp.MultiTenancy;
using Volo.Abp.Users;
using Volo.Abp.Uow;

namespace LaundrySaaS.EventHandlers;

public class OrderPaymentRecordedEventHandler : ILocalEventHandler<OrderPaymentRecordedEto>, ITransientDependency
{
    private readonly IAccountRepository _accountRepository;
    private readonly IJournalEntryRepository _journalEntryRepository;
    private readonly JournalEntryManager _journalEntryManager;
    private readonly PartyAccountManager _partyAccountManager;
    private readonly AccountingDataSeedContributor _dataSeedContributor;
    private readonly ICurrentTenant _currentTenant;
    private readonly ICurrentUser _currentUser;
    private readonly IGuidGenerator _guidGenerator;
    private readonly IDataFilter _dataFilter;
    private readonly ILogger<OrderPaymentRecordedEventHandler> _logger;

    public OrderPaymentRecordedEventHandler(
        IAccountRepository accountRepository,
        IJournalEntryRepository journalEntryRepository,
        JournalEntryManager journalEntryManager,
        PartyAccountManager partyAccountManager,
        AccountingDataSeedContributor dataSeedContributor,
        ICurrentTenant currentTenant,
        ICurrentUser currentUser,
        IGuidGenerator guidGenerator,
        IDataFilter dataFilter,
        ILogger<OrderPaymentRecordedEventHandler> logger)
    {
        _accountRepository = accountRepository;
        _journalEntryRepository = journalEntryRepository;
        _journalEntryManager = journalEntryManager;
        _partyAccountManager = partyAccountManager;
        _dataSeedContributor = dataSeedContributor;
        _currentTenant = currentTenant;
        _currentUser = currentUser;
        _guidGenerator = guidGenerator;
        _dataFilter = dataFilter;
        _logger = logger;
    }

    [UnitOfWork]
    public virtual async Task HandleEventAsync(OrderPaymentRecordedEto eventData)
    {
        if (eventData.Amount <= 0)
        {
            return;
        }

        using (_currentTenant.Change(eventData.TenantId))
        {
            try
            {
                _logger.LogInformation("Generating payment settlement journal entry for Order: {OrderNumber}, Amount: {Amount}, Method: {Method}",
                    eventData.OrderNumber, eventData.Amount, eventData.PaymentMethod);

                // 1. Ensure tenant Chart of Accounts is available
                await EnsureTenantChartOfAccountsAsync(eventData.TenantId);

                // 2. Resolve Cash / Bank Account
                var cashAccount = await GetAccountByCodeAsync("1101");
                var bankAccount = await GetAccountByCodeAsync("1102");

                var isBank = eventData.PaymentMethod == PaymentMethod.Card || eventData.PaymentMethod == PaymentMethod.Transfer;
                var paymentTargetAccount = isBank && bankAccount != null ? bankAccount : cashAccount;

                if (paymentTargetAccount == null)
                {
                    _logger.LogError("Cash / Bank account not found for Tenant: {TenantId}", eventData.TenantId);
                    return;
                }

                // 3. Resolve Customer Account under 1103
                var customerEntityId = eventData.CustomerId ?? Guid.Parse("00000000-0000-0000-0000-000000000001");
                var customerName = string.IsNullOrWhiteSpace(eventData.CustomerName) ? "عميل نقدي عام" : eventData.CustomerName;
                var customerAccount = await _partyAccountManager.GetOrCreateAccountAsync(
                    PartyType.Customer,
                    customerEntityId,
                    customerName,
                    eventData.TenantId
                );

                // 4. Generate Entry Number & Create Entry
                var entryNumber = await _journalEntryManager.GenerateEntryNumberAsync(eventData.PaymentDate);
                var desc = eventData.IsDeliverySettlement
                    ? $"سداد متبقي فاتورة مغسلة رقم {eventData.OrderNumber} عند التسليم - العميل: {customerName}"
                    : $"سند قبض دفعة لفاتورة مغسلة رقم {eventData.OrderNumber} - العميل: {customerName}";

                var entry = new JournalEntry(
                    _guidGenerator.Create(),
                    eventData.TenantId,
                    entryNumber,
                    eventData.PaymentDate,
                    desc,
                    JournalEntryType.Automatic,
                    sourceModule: "Orders",
                    sourceEntityId: eventData.OrderId
                );

                // 5. Debit: Cash / Bank
                entry.AddLine(
                    paymentTargetAccount.Id,
                    debit: eventData.Amount,
                    credit: 0,
                    description: $"تحصيل سداد ({eventData.PaymentMethod}) - فاتورة {eventData.OrderNumber}",
                    reference: eventData.OrderNumber
                );

                // 6. Credit: Customer Receivable Account (Closing customer balance)
                entry.AddLine(
                    customerAccount.Id,
                    debit: 0,
                    credit: eventData.Amount,
                    description: $"إقفال ذمة العميل لسداد متبقي الفاتورة {eventData.OrderNumber}",
                    reference: eventData.OrderNumber
                );

                // 7. Post and Save
                var userId = _currentUser.Id ?? Guid.Empty;
                await _journalEntryManager.PostEntryAsync(entry, userId);
                await _journalEntryRepository.InsertAsync(entry, autoSave: true);

                _logger.LogInformation("Successfully posted payment settlement JournalEntry {EntryNumber} for Order {OrderNumber}. Amount: {Amount}",
                    entry.EntryNumber, eventData.OrderNumber, eventData.Amount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create payment settlement journal entry for Order {OrderNumber}", eventData.OrderNumber);
                throw;
            }
        }
    }

    private async Task EnsureTenantChartOfAccountsAsync(Guid? tenantId)
    {
        var existing = await _accountRepository.FindByCodeAsync("1101");
        if (existing == null)
        {
            await _dataSeedContributor.SeedAsync(new DataSeedContext(tenantId));
        }
    }

    private async Task<Account?> GetAccountByCodeAsync(string code)
    {
        var account = await _accountRepository.FindByCodeAsync(code);
        if (account != null) return account;

        using (_dataFilter.Disable<IMultiTenant>())
        {
            return await _accountRepository.FindByCodeAsync(code);
        }
    }
}
