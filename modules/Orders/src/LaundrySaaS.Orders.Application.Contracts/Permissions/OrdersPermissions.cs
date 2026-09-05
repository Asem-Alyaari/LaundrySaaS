using Volo.Abp.Reflection;

namespace LaundrySaaS.Orders.Permissions;

public class OrdersPermissions
{
    public const string GroupName = "Orders";

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(OrdersPermissions));
    }
}
