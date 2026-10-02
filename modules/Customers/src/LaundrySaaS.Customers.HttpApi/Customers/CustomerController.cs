using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
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

    [HttpPost("register")]
    [AllowAnonymous]
    public virtual Task<RegisterCustomerResultDto> RegisterAsync([FromBody] RegisterCustomerDto input)
    {
        return _customerAppService.RegisterAsync(input);
    }

    [HttpGet("{customerId}/addresses")]
    [AllowAnonymous]
    public virtual Task<List<CustomerAddressDto>> GetAddressesAsync(Guid customerId)
    {
        return _customerAppService.GetAddressesAsync(customerId);
    }

    [HttpPost("{customerId}/addresses")]
    [AllowAnonymous]
    public virtual Task<CustomerAddressDto> AddAddressAsync(Guid customerId, [FromBody] CreateUpdateCustomerAddressDto input)
    {
        return _customerAppService.AddAddressAsync(customerId, input);
    }

    [HttpPut("addresses/{addressId}")]
    [AllowAnonymous]
    public virtual Task<CustomerAddressDto> UpdateAddressAsync(Guid addressId, [FromBody] CreateUpdateCustomerAddressDto input)
    {
        return _customerAppService.UpdateAddressAsync(addressId, input);
    }

    [HttpDelete("addresses/{addressId}")]
    [AllowAnonymous]
    public virtual Task DeleteAddressAsync(Guid addressId)
    {
        return _customerAppService.DeleteAddressAsync(addressId);
    }

    [HttpPost("addresses/{addressId}/set-default")]
    [AllowAnonymous]
    public virtual Task SetDefaultAddressAsync(Guid addressId)
    {
        return _customerAppService.SetDefaultAddressAsync(addressId);
    }
}
