using System.Threading.Tasks;
using Volo.Abp.UI.Navigation;

namespace LaundrySaaS.Blazor.Menus;

public class LaundrySaaSMenuContributor : IMenuContributor
{
    public async Task ConfigureMenuAsync(MenuConfigurationContext context)
    {
        if (context.Menu.Name == StandardMenus.Main)
        {
            await ConfigureMainMenuAsync(context);
        }
    }

    private Task ConfigureMainMenuAsync(MenuConfigurationContext context)
    {
        //Add main menu items.
        context.Menu.AddItem(new ApplicationMenuItem(LaundrySaaSMenus.Prefix, displayName: "LaundrySaaS", "/LaundrySaaS", icon: "fa fa-globe"));

        return Task.CompletedTask;
    }
}
