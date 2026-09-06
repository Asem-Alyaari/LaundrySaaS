using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Customers.Customers;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Customers.Customers;

public class CustomerAppService :
    CrudAppService<
        Customer,
        CustomerDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateCustomerDto>,
    ICustomerAppService
{
    public CustomerAppService(IRepository<Customer, Guid> repository)
        : base(repository)
    {
    }

    public async Task<List<CustomerDto>> SearchAsync(string? filter)
    {
        var query = await Repository.GetQueryableAsync();

        if (!string.IsNullOrWhiteSpace(filter))
        {
            var term = filter.Trim();
            query = query.Where(c => c.FullName.Contains(term) || c.PhoneNumber.Contains(term));
        }

        var list = await AsyncExecuter.ToListAsync(query.OrderBy(c => c.FullName).Take(50));
        return list.Select(MapToGetOutputDto).ToList();
    }

    protected override Customer MapToEntity(CreateUpdateCustomerDto createInput)
    {
        var address = new Address(
            createInput.Address.City,
            createInput.Address.District,
            createInput.Address.Street,
            createInput.Address.BuildingNumber
        );

        return new Customer(GuidGenerator.Create(), createInput.FullName, createInput.PhoneNumber, address);
    }

    protected override void MapToEntity(CreateUpdateCustomerDto updateInput, Customer entity)
    {
        var address = new Address(
            updateInput.Address.City,
            updateInput.Address.District,
            updateInput.Address.Street,
            updateInput.Address.BuildingNumber
        );

        entity.Update(updateInput.FullName, updateInput.PhoneNumber, address);
    }
}
