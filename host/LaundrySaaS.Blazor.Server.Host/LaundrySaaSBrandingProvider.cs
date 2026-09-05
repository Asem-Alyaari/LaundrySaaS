using Volo.Abp.DependencyInjection;
using Volo.Abp.Ui.Branding;

namespace LaundrySaaS.Blazor.Server.Host;

[Dependency(ReplaceServices = true)]
public class LaundrySaaSBrandingProvider : DefaultBrandingProvider
{
    public override string AppName => "LaundrySaaS";
}
