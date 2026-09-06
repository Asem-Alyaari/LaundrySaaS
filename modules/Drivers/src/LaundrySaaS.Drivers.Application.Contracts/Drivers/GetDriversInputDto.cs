using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Drivers.Drivers;

public class GetDriversInputDto : PagedAndSortedResultRequestDto
{
    public string? Filter { get; set; }
    public bool? IsAvailable { get; set; }
    public System.Guid? LaundryId { get; set; }
}
