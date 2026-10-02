using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Customers.Customers;

public interface ICustomerAppService :
    ICrudAppService<
        CustomerDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateCustomerDto>
{
    Task<List<CustomerDto>> SearchAsync(string? filter);
    Task<RegisterCustomerResultDto> RegisterAsync(RegisterCustomerDto input);

    Task<List<CustomerAddressDto>> GetAddressesAsync(Guid customerId);
    Task<CustomerAddressDto> AddAddressAsync(Guid customerId, CreateUpdateCustomerAddressDto input);
    Task<CustomerAddressDto> UpdateAddressAsync(Guid addressId, CreateUpdateCustomerAddressDto input);
    Task DeleteAddressAsync(Guid addressId);
    Task SetDefaultAddressAsync(Guid addressId);
}
