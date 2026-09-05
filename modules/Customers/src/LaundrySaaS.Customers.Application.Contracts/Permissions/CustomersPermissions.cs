using Volo.Abp.Reflection;

namespace LaundrySaaS.Customers.Permissions;

public class CustomersPermissions
{
    public const string GroupName = "Customers";

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(CustomersPermissions));
    }
}
