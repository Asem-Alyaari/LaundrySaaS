using System;
using System.Collections.Generic;
using System.Threading.Tasks;
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
    Task<List<LaundryDto>> GetNearbyAsync(double lat, double lng, double radiusKm);
}
