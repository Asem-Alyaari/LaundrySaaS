using System;
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
