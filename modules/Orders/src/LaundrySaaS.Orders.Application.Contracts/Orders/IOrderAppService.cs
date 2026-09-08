using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Orders.Orders;

public interface IOrderAppService : IApplicationService
{
    Task<OrderDto> CreateAsync(CreateOrderDto input);
    Task<OrderDto> GetAsync(Guid id);
    Task<PagedResultDto<OrderDto>> GetListAsync(GetOrdersInputDto input);
    Task<OrderDto> UpdateStatusAsync(Guid id, OrderStatus status);
    Task<OrderDto> RecordPaymentAsync(Guid id, RecordOrderPaymentDto input);
    Task<LaundryReportDto> GetReportAsync(GetLaundryReportInputDto input);
}
