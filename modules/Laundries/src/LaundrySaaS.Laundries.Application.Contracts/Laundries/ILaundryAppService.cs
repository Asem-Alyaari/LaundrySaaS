using System;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Laundries.Laundries;

public interface ILaundryAppService :
    ICrudAppService<
        LaundryDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateLaundryDto>
{
}
