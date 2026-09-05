using Volo.Abp.Reflection;

namespace LaundrySaaS.Permissions;

public class LaundrySaaSPermissions
{
    public const string GroupName = "LaundrySaaS";

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(LaundrySaaSPermissions));
    }
}
