using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Orders.Orders;

[RemoteService(Name = "Orders")]
[Area("orders")]
[Route("api/orders/orders")]
public class OrderController : OrdersController, IOrderAppService
{
    private readonly IOrderAppService _orderAppService;

    public OrderController(IOrderAppService orderAppService)
    {
        _orderAppService = orderAppService;
    }

    [HttpPost]
    public Task<OrderDto> CreateAsync([FromBody] CreateOrderDto input)
    {
        return _orderAppService.CreateAsync(input);
    }

    [HttpGet("{id}")]
    public Task<OrderDto> GetAsync(Guid id)
    {
        return _orderAppService.GetAsync(id);
    }

    [HttpGet]
    public Task<PagedResultDto<OrderDto>> GetListAsync([FromQuery] GetOrdersInputDto input)
    {
        return _orderAppService.GetListAsync(input);
    }

    [HttpPut("{id}/status")]
    public Task<OrderDto> UpdateStatusAsync(Guid id, [FromQuery] OrderStatus status)
    {
        return _orderAppService.UpdateStatusAsync(id, status);
    }

    [HttpPost("{id}/pay")]
    public Task<OrderDto> RecordPaymentAsync(Guid id, [FromBody] RecordOrderPaymentDto input)
    {
        return _orderAppService.RecordPaymentAsync(id, input);
    }

    [HttpGet("report")]
    public Task<LaundryReportDto> GetReportAsync([FromQuery] GetLaundryReportInputDto input)
    {
        return _orderAppService.GetReportAsync(input);
    }
}
