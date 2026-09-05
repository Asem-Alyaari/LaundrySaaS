using LaundrySaaS.Laundries.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace LaundrySaaS.Laundries.Permissions;

public class LaundriesPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(LaundriesPermissions.GroupName, L("Permission:Laundries"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<LaundriesResource>(name);
    }
}
