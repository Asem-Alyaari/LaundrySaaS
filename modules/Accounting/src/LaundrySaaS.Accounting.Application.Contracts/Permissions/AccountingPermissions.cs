using Volo.Abp.Reflection;

namespace LaundrySaaS.Accounting.Permissions;

public class AccountingPermissions
{
    public const string GroupName = "Accounting";

    public static class Accounts
    {
        public const string Default = GroupName + ".Accounts";
        public const string Create = Default + ".Create";
        public const string Update = Default + ".Update";
        public const string Delete = Default + ".Delete";
    }

    public static class JournalEntries
    {
        public const string Default = GroupName + ".JournalEntries";
        public const string Create = Default + ".Create";
        public const string Update = Default + ".Update";
        public const string Post = Default + ".Post";
        public const string Cancel = Default + ".Cancel";
    }

    public static class FiscalYears
    {
        public const string Default = GroupName + ".FiscalYears";
        public const string Manage = Default + ".Manage";
    }

    public static class CostCenters
    {
        public const string Default = GroupName + ".CostCenters";
        public const string Manage = Default + ".Manage";
    }

    public static class Reports
    {
        public const string Default = GroupName + ".Reports";
        public const string View = Default + ".View";
    }

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(AccountingPermissions));
    }
}
