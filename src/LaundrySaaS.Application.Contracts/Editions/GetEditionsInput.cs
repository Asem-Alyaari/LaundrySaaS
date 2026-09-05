using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Editions;

public class GetEditionsInput : PagedAndSortedResultRequestDto
{
    public string? Filter { get; set; }
}
