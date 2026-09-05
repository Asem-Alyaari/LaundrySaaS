using Volo.Abp.Reflection;

namespace LaundrySaaS.Laundries.Permissions;

public class LaundriesPermissions
{
    public const string GroupName = "Laundries";

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(LaundriesPermissions));
    }
}
