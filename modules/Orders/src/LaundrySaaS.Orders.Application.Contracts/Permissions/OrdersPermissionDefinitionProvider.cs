using LaundrySaaS.Orders.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace LaundrySaaS.Orders.Permissions;

public class OrdersPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(OrdersPermissions.GroupName, L("Permission:Orders"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<OrdersResource>(name);
    }
}
