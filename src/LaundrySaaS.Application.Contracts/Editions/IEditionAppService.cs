using System;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Editions;

public interface IEditionAppService :
    ICrudAppService<
        EditionDto,
        Guid,
        GetEditionsInput,
        CreateEditionDto,
        UpdateEditionDto>
{
}
