using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Laundries.Items;

public interface IServiceItemAppService :
    ICrudAppService<
        ServiceItemDto,
        Guid,
        GetServiceItemsInput,
        CreateUpdateServiceItemDto>
{
    Task<List<ServiceItemDto>> ImportTemplateCatalogAsync(Guid laundryId);
}
