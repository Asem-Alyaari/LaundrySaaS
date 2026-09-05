using Volo.Abp.Ui.Branding;
using Volo.Abp.DependencyInjection;

namespace LaundrySaaS;

[Dependency(ReplaceServices = true)]
public class LaundrySaaSBrandingProvider : DefaultBrandingProvider
{
    public override string AppName => "LaundrySaaS";
}
