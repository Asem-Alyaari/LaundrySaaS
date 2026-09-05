using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Laundries.Categories;

public interface IServiceCategoryAppService :
    ICrudAppService<
        ServiceCategoryDto,
        Guid,
        GetServiceCategoriesInput,
        CreateUpdateServiceCategoryDto>
{
    Task<ListResultDto<ServiceCategoryDto>> GetAllAsync(Guid? laundryId = null);
}
