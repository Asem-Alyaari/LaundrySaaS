using LaundrySaaS.Accounting.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace LaundrySaaS.Accounting.Permissions;

public class AccountingPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var accountingGroup = context.AddGroup(AccountingPermissions.GroupName, L("Permission:Accounting"));

        var accountsPermission = accountingGroup.AddPermission(AccountingPermissions.Accounts.Default, L("Permission:Accounts"));
        accountsPermission.AddChild(AccountingPermissions.Accounts.Create, L("Permission:Create"));
        accountsPermission.AddChild(AccountingPermissions.Accounts.Update, L("Permission:Update"));
        accountsPermission.AddChild(AccountingPermissions.Accounts.Delete, L("Permission:Delete"));

        var journalEntriesPermission = accountingGroup.AddPermission(AccountingPermissions.JournalEntries.Default, L("Permission:JournalEntries"));
        journalEntriesPermission.AddChild(AccountingPermissions.JournalEntries.Create, L("Permission:Create"));
        journalEntriesPermission.AddChild(AccountingPermissions.JournalEntries.Update, L("Permission:Update"));
        journalEntriesPermission.AddChild(AccountingPermissions.JournalEntries.Post, L("Permission:Post"));
        journalEntriesPermission.AddChild(AccountingPermissions.JournalEntries.Cancel, L("Permission:Cancel"));

        var fiscalYearsPermission = accountingGroup.AddPermission(AccountingPermissions.FiscalYears.Default, L("Permission:FiscalYears"));
        fiscalYearsPermission.AddChild(AccountingPermissions.FiscalYears.Manage, L("Permission:Manage"));

        var costCentersPermission = accountingGroup.AddPermission(AccountingPermissions.CostCenters.Default, L("Permission:CostCenters"));
        costCentersPermission.AddChild(AccountingPermissions.CostCenters.Manage, L("Permission:Manage"));

        var reportsPermission = accountingGroup.AddPermission(AccountingPermissions.Reports.Default, L("Permission:Reports"));
        reportsPermission.AddChild(AccountingPermissions.Reports.View, L("Permission:View"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<AccountingResource>(name);
    }
}
