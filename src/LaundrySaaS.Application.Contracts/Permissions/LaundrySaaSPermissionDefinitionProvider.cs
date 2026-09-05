using LaundrySaaS.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace LaundrySaaS.Permissions;

public class LaundrySaaSPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(LaundrySaaSPermissions.GroupName, L("Permission:LaundrySaaS"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<LaundrySaaSResource>(name);
    }
}
