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

public class OrderCreatedEventHandler : ILocalEventHandler<OrderCreatedEto>, ITransientDependency
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
    private readonly ILogger<OrderCreatedEventHandler> _logger;

    public OrderCreatedEventHandler(
        IAccountRepository accountRepository,
        IJournalEntryRepository journalEntryRepository,
        JournalEntryManager journalEntryManager,
        PartyAccountManager partyAccountManager,
        AccountingDataSeedContributor dataSeedContributor,
        ICurrentTenant currentTenant,
        ICurrentUser currentUser,
        IGuidGenerator guidGenerator,
        IDataFilter dataFilter,
        ILogger<OrderCreatedEventHandler> logger)
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
    public virtual async Task HandleEventAsync(OrderCreatedEto eventData)
    {
        if (eventData.TotalAmount <= 0)
        {
            _logger.LogInformation("Order {OrderNumber} has zero total amount, skipping accounting journal entry.", eventData.OrderNumber);
            return;
        }

        using (_currentTenant.Change(eventData.TenantId))
        {
            try
            {
                _logger.LogInformation("Generating double-entry accounting journal for Order: {OrderNumber} (Total: {Total}, Paid: {Paid}, Remaining: {Remaining})",
                    eventData.OrderNumber, eventData.TotalAmount, eventData.PaidAmount, eventData.RemainingAmount);

                // 1. Ensure tenant Chart of Accounts is available
                await EnsureTenantChartOfAccountsAsync(eventData.TenantId);

                // 2. Fetch Accounts
                var cashAccount = await GetAccountByCodeAsync("1101");
                var bankAccount = await GetAccountByCodeAsync("1102");
                var revenueAccount = await GetAccountByCodeAsync("4101");
                var vatAccount = await GetAccountByCodeAsync("2102");

                if (cashAccount == null || revenueAccount == null)
                {
                    _logger.LogError("Essential accounting accounts (1101/4101) not found for Tenant: {TenantId}", eventData.TenantId);
                    return;
                }

                // 3. Get or create Customer Account under 1103
                var customerEntityId = eventData.CustomerId ?? Guid.Parse("00000000-0000-0000-0000-000000000001");
                var customerName = string.IsNullOrWhiteSpace(eventData.CustomerName) ? "عميل نقدي عام" : eventData.CustomerName;
                var customerAccount = await _partyAccountManager.GetOrCreateAccountAsync(
                    PartyType.Customer,
                    customerEntityId,
                    customerName,
                    eventData.TenantId
                );

                // 4. Generate Entry Number & Create Entry
                var entryNumber = await _journalEntryManager.GenerateEntryNumberAsync(eventData.CreationTime);
                var isPartialOrUnpaid = eventData.RemainingAmount > 0;
                var desc = isPartialOrUnpaid
                    ? $"فاتورة مبيعات مغسلة رقم {eventData.OrderNumber} (دفع جزئي/آجل) - العميل: {customerName}"
                    : $"فاتورة مبيعات مغسلة رقم {eventData.OrderNumber} - العميل: {customerName}";

                var entry = new JournalEntry(
                    _guidGenerator.Create(),
                    eventData.TenantId,
                    entryNumber,
                    eventData.CreationTime,
                    desc,
                    JournalEntryType.Automatic,
                    sourceModule: "Orders",
                    sourceEntityId: eventData.OrderId
                );

                // 5. Debit Lines
                // 5a. Paid portion -> Cash or Bank
                if (eventData.PaidAmount > 0)
                {
                    var isBank = eventData.PaymentMethod == PaymentMethod.Card || eventData.PaymentMethod == PaymentMethod.Transfer;
                    var paymentTargetAccount = isBank && bankAccount != null ? bankAccount : cashAccount;

                    entry.AddLine(
                        paymentTargetAccount.Id,
                        debit: eventData.PaidAmount,
                        credit: 0,
                        description: $"تحصيل دفعة الفاتورة ({eventData.PaymentMethod}) - {eventData.OrderNumber}",
                        reference: eventData.OrderNumber
                    );
                }

                // 5b. Remaining portion -> Customer Receivable
                if (eventData.RemainingAmount > 0)
                {
                    entry.AddLine(
                        customerAccount.Id,
                        debit: eventData.RemainingAmount,
                        credit: 0,
                        description: $"متبقي آجل على العميل - فاتورة {eventData.OrderNumber}",
                        reference: eventData.OrderNumber
                    );
                }

                // 6. Credit Lines
                // 6a. Revenue
                var netRevenue = eventData.TaxAmount > 0
                    ? Math.Max(0, eventData.TotalAmount - eventData.TaxAmount)
                    : eventData.TotalAmount;

                if (netRevenue > 0)
                {
                    entry.AddLine(
                        revenueAccount.Id,
                        debit: 0,
                        credit: netRevenue,
                        description: $"إيراد خدمات غسيل - فاتورة {eventData.OrderNumber}",
                        reference: eventData.OrderNumber
                    );
                }

                // 6b. VAT Output
                if (eventData.TaxAmount > 0 && vatAccount != null)
                {
                    entry.AddLine(
                        vatAccount.Id,
                        debit: 0,
                        credit: eventData.TaxAmount,
                        description: $"ضريبة القيمة المضافة المستحقة - فاتورة {eventData.OrderNumber}",
                        reference: eventData.OrderNumber
                    );
                }

                // 7. Post and Save
                var userId = _currentUser.Id ?? Guid.Empty;
                await _journalEntryManager.PostEntryAsync(entry, userId);
                await _journalEntryRepository.InsertAsync(entry, autoSave: true);

                _logger.LogInformation("Successfully posted JournalEntry {EntryNumber} for Order {OrderNumber}. Total Debit: {Debit}, Total Credit: {Credit}",
                    entry.EntryNumber, eventData.OrderNumber, entry.TotalDebit, entry.TotalCredit);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create accounting journal entry for Order {OrderNumber}", eventData.OrderNumber);
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

        // Fallback to host accounts if not isolated
        using (_dataFilter.Disable<IMultiTenant>())
        {
            return await _accountRepository.FindByCodeAsync(code);
        }
    }
}
