using System.Threading.Tasks;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Orders.Samples;

public interface ISampleAppService : IApplicationService
{
    Task<SampleDto> GetAsync();

    Task<SampleDto> GetAuthorizedAsync();
}
