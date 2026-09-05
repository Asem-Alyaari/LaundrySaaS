using System.Threading.Tasks;
using Volo.Abp.UI.Navigation;

namespace LaundrySaaS.Laundries.Blazor.Menus;

public class LaundriesMenuContributor : IMenuContributor
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
        context.Menu.AddItem(new ApplicationMenuItem(LaundriesMenus.Prefix, displayName: "Laundries", "/Laundries", icon: "fa fa-globe"));

        return Task.CompletedTask;
    }
}
