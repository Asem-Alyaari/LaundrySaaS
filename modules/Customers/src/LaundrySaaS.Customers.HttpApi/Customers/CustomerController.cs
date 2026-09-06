using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Customers.Customers;

[RemoteService(Name = "Customers")]
[Area("customers")]
[Route("api/customers/customers")]
public class CustomerController : CustomersController, ICustomerAppService
{
    private readonly ICustomerAppService _customerAppService;

    public CustomerController(ICustomerAppService customerAppService)
    {
        _customerAppService = customerAppService;
    }

    [HttpGet]
    public virtual Task<PagedResultDto<CustomerDto>> GetListAsync([FromQuery] PagedAndSortedResultRequestDto input)
    {
        return _customerAppService.GetListAsync(input);
    }

    [HttpGet("search")]
    public virtual Task<List<CustomerDto>> SearchAsync([FromQuery] string? filter)
    {
        return _customerAppService.SearchAsync(filter);
    }

    [HttpGet("{id}")]
    public virtual Task<CustomerDto> GetAsync(Guid id)
    {
        return _customerAppService.GetAsync(id);
    }

    [HttpPost]
    public virtual Task<CustomerDto> CreateAsync([FromBody] CreateUpdateCustomerDto input)
    {
        return _customerAppService.CreateAsync(input);
    }

    [HttpPut("{id}")]
    public virtual Task<CustomerDto> UpdateAsync(Guid id, [FromBody] CreateUpdateCustomerDto input)
    {
        return _customerAppService.UpdateAsync(id, input);
    }

    [HttpDelete("{id}")]
    public virtual Task DeleteAsync(Guid id)
    {
        return _customerAppService.DeleteAsync(id);
    }
}
