using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Guids;
using Volo.Abp.MultiTenancy;

namespace LaundrySaaS.Accounting.Data;

public class AccountingDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IAccountRepository _accountRepository;
    private readonly IGuidGenerator _guidGenerator;
    private readonly ICurrentTenant _currentTenant;

    public AccountingDataSeedContributor(
        IAccountRepository accountRepository,
        IGuidGenerator guidGenerator,
        ICurrentTenant currentTenant)
    {
        _accountRepository = accountRepository;
        _guidGenerator = guidGenerator;
        _currentTenant = currentTenant;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _accountRepository.GetCountAsync() > 0)
        {
            return;
        }

        var tenantId = _currentTenant.Id;

        // 1. Assets
        var assets = await CreateAccountAsync(tenantId, "1", "الأصول", "Assets", AccountType.Asset, AccountNormalBalance.Debit, null, 1, false);
        var currentAssets = await CreateAccountAsync(tenantId, "11", "الأصول المتداولة", "Current Assets", AccountType.Asset, AccountNormalBalance.Debit, assets.Id, 2, false);
        await CreateAccountAsync(tenantId, "1101", "الصندوق / الخزينة", "Cash on Hand", AccountType.Asset, AccountNormalBalance.Debit, currentAssets.Id, 3, true);
        await CreateAccountAsync(tenantId, "1102", "الحسابات البنكية", "Bank Accounts", AccountType.Asset, AccountNormalBalance.Debit, currentAssets.Id, 3, true);
        await CreateAccountAsync(tenantId, "1103", "ذمم العملاء", "Accounts Receivable", AccountType.Asset, AccountNormalBalance.Debit, currentAssets.Id, 3, false);
        await CreateAccountAsync(tenantId, "1104", "مخزون مواد الغسيل", "Laundry Supplies Inventory", AccountType.Asset, AccountNormalBalance.Debit, currentAssets.Id, 3, true);
        await CreateAccountAsync(tenantId, "1105", "عهد ونقدية المناديب", "Drivers Cash / Custody", AccountType.Asset, AccountNormalBalance.Debit, currentAssets.Id, 3, false);

        var fixedAssets = await CreateAccountAsync(tenantId, "12", "الأصول الثابتة", "Fixed Assets", AccountType.Asset, AccountNormalBalance.Debit, assets.Id, 2, false);
        await CreateAccountAsync(tenantId, "1201", "غسالات ومعدات الغسيل", "Washing Equipment", AccountType.Asset, AccountNormalBalance.Debit, fixedAssets.Id, 3, true);
        await CreateAccountAsync(tenantId, "1202", "مركبات التوصيل", "Delivery Vehicles", AccountType.Asset, AccountNormalBalance.Debit, fixedAssets.Id, 3, true);

        // 2. Liabilities
        var liabilities = await CreateAccountAsync(tenantId, "2", "الخصوم والالتزامات", "Liabilities", AccountType.Liability, AccountNormalBalance.Credit, null, 1, false);
        var currentLiabilities = await CreateAccountAsync(tenantId, "21", "الخصوم المتداولة", "Current Liabilities", AccountType.Liability, AccountNormalBalance.Credit, liabilities.Id, 2, false);
        await CreateAccountAsync(tenantId, "2101", "ذمم الموردين", "Accounts Payable", AccountType.Liability, AccountNormalBalance.Credit, currentLiabilities.Id, 3, true);
        await CreateAccountAsync(tenantId, "2102", "ضريبة القيمة المضافة المستحقة", "VAT Output Payable", AccountType.Liability, AccountNormalBalance.Credit, currentLiabilities.Id, 3, true);
        await CreateAccountAsync(tenantId, "2103", "مصروفات مستحقة", "Accrued Expenses", AccountType.Liability, AccountNormalBalance.Credit, currentLiabilities.Id, 3, true);

        // 3. Equity
        var equity = await CreateAccountAsync(tenantId, "3", "حقوق الملكية", "Equity", AccountType.Equity, AccountNormalBalance.Credit, null, 1, false);
        await CreateAccountAsync(tenantId, "3101", "رأس المال", "Capital", AccountType.Equity, AccountNormalBalance.Credit, equity.Id, 2, true);
        await CreateAccountAsync(tenantId, "3201", "الأرباح المبقاة", "Retained Earnings", AccountType.Equity, AccountNormalBalance.Credit, equity.Id, 2, true);

        // 4. Revenue
        var revenue = await CreateAccountAsync(tenantId, "4", "الإيرادات", "Revenue", AccountType.Revenue, AccountNormalBalance.Credit, null, 1, false);
        var opRevenue = await CreateAccountAsync(tenantId, "41", "إيرادات التشغيل", "Operating Revenue", AccountType.Revenue, AccountNormalBalance.Credit, revenue.Id, 2, false);
        await CreateAccountAsync(tenantId, "4101", "إيرادات غسيل الملابس", "Laundry Services Revenue", AccountType.Revenue, AccountNormalBalance.Credit, opRevenue.Id, 3, true);
        await CreateAccountAsync(tenantId, "4102", "إيرادات الكي والتنظيف الجاف", "Dry Clean Revenue", AccountType.Revenue, AccountNormalBalance.Credit, opRevenue.Id, 3, true);
        await CreateAccountAsync(tenantId, "4103", "إيرادات رسوم التوصيل", "Delivery Fees Revenue", AccountType.Revenue, AccountNormalBalance.Credit, opRevenue.Id, 3, true);

        // 5. Expenses
        var expenses = await CreateAccountAsync(tenantId, "5", "المصروفات", "Expenses", AccountType.Expense, AccountNormalBalance.Debit, null, 1, false);
        var opExpenses = await CreateAccountAsync(tenantId, "51", "تكاليف التشغيل المباشرة", "Operating Expenses", AccountType.Expense, AccountNormalBalance.Debit, expenses.Id, 2, false);
        await CreateAccountAsync(tenantId, "5101", "منظفات ومواد كيماوية", "Detergents & Chemicals", AccountType.Expense, AccountNormalBalance.Debit, opExpenses.Id, 3, true);
        await CreateAccountAsync(tenantId, "5102", "مياه وكهرباء", "Water & Electricity", AccountType.Expense, AccountNormalBalance.Debit, opExpenses.Id, 3, true);
        await CreateAccountAsync(tenantId, "5103", "صيانة وإصلاح المعدات", "Equipment Maintenance", AccountType.Expense, AccountNormalBalance.Debit, opExpenses.Id, 3, true);

        var adminExpenses = await CreateAccountAsync(tenantId, "52", "مصروفات عمومية وإدارية", "General & Administrative Expenses", AccountType.Expense, AccountNormalBalance.Debit, expenses.Id, 2, false);
        await CreateAccountAsync(tenantId, "5201", "رواتب وأجور", "Salaries & Wages", AccountType.Expense, AccountNormalBalance.Debit, adminExpenses.Id, 3, true);
        await CreateAccountAsync(tenantId, "5202", "إيجارات المحلات", "Rent Expense", AccountType.Expense, AccountNormalBalance.Debit, adminExpenses.Id, 3, true);
        await CreateAccountAsync(tenantId, "5203", "وقود ومصاريف سيارات", "Fuel & Vehicle Expenses", AccountType.Expense, AccountNormalBalance.Debit, adminExpenses.Id, 3, true);
    }

    private async Task<Account> CreateAccountAsync(
        Guid? tenantId,
        string code,
        string name,
        string englishName,
        AccountType type,
        AccountNormalBalance normalBalance,
        Guid? parentId,
        int level,
        bool allowDirectPosting)
    {
        var account = new Account(
            _guidGenerator.Create(),
            tenantId,
            code,
            name,
            type,
            normalBalance,
            parentId,
            level,
            allowDirectPosting,
            currency: "SAR",
            englishName: englishName
        );

        return await _accountRepository.InsertAsync(account);
    }
}
