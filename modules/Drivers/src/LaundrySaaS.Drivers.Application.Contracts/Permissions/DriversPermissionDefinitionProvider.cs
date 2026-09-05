using LaundrySaaS.Drivers.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace LaundrySaaS.Drivers.Permissions;

public class DriversPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(DriversPermissions.GroupName, L("Permission:Drivers"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<DriversResource>(name);
    }
}
