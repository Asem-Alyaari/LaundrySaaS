using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;

namespace LaundrySaaS.Pages;

public class IndexModel : LaundrySaaSPageModel
{
    public void OnGet()
    {

    }

    public async Task OnPostLoginAsync()
    {
        await HttpContext.ChallengeAsync("oidc");
    }
}
