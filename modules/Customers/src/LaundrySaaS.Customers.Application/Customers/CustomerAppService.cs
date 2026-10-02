using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Customers.Customers;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Microsoft.AspNetCore.Identity;
using Volo.Abp.Identity;
using Microsoft.AspNetCore.Authorization;

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
    private readonly IdentityUserManager _userManager;
    private readonly IRepository<CustomerAddress, Guid> _addressRepository;

    public CustomerAppService(
        IRepository<Customer, Guid> repository,
        IdentityUserManager userManager,
        IRepository<CustomerAddress, Guid> addressRepository)
        : base(repository)
    {
        _userManager = userManager;
        _addressRepository = addressRepository;
    }

    [AllowAnonymous]
    public async Task<RegisterCustomerResultDto> RegisterAsync(RegisterCustomerDto input)
    {
        // 1. Create ABP Identity user with PhoneNumber as UserName
        var identityUser = new Volo.Abp.Identity.IdentityUser(
            GuidGenerator.Create(),
            input.PhoneNumber.Trim(),   // UserName = phone number
            input.Email.Trim().Length > 0 ? input.Email.Trim() : $"{input.PhoneNumber.Trim()}@customer.laundrysaas.com",
            CurrentTenant.Id
        );
        identityUser.Name = input.FullName.Trim();
        identityUser.SetPhoneNumber(input.PhoneNumber.Trim(), confirmed: true);

        var createResult = await _userManager.CreateAsync(identityUser, input.Password);
        if (!createResult.Succeeded)
        {
            var errors = string.Join(", ", createResult.Errors.Select(e => e.Description));
            return new RegisterCustomerResultDto
            {
                Success = false,
                ErrorMessage = errors
            };
        }

        // 2. Create Customer entity
        var address = new Address("غير محدد", "غير محدد", "غير محدد", "غير محدد");
        var customer = new Customer(
            GuidGenerator.Create(),
            input.FullName.Trim(),
            input.PhoneNumber.Trim(),
            input.Email.Trim(),
            address
        );
        await Repository.InsertAsync(customer, autoSave: true);

        return new RegisterCustomerResultDto
        {
            CustomerId = customer.Id,
            FullName = customer.FullName,
            PhoneNumber = customer.PhoneNumber,
            Email = customer.Email,
            Success = true
        };
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

        return new Customer(GuidGenerator.Create(), createInput.FullName, createInput.PhoneNumber, createInput.Email ?? string.Empty, address);
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

    [AllowAnonymous]
    public async Task<List<CustomerAddressDto>> GetAddressesAsync(Guid customerId)
    {
        var query = await _addressRepository.GetQueryableAsync();
        var list = await AsyncExecuter.ToListAsync(
            query.Where(a => a.CustomerId == customerId)
                 .OrderByDescending(a => a.IsDefault)
                 .ThenByDescending(a => a.CreationTime)
        );

        return list.Select(a => new CustomerAddressDto
        {
            Id = a.Id,
            CustomerId = a.CustomerId,
            Title = a.Title,
            AddressType = a.AddressType,
            Latitude = a.Latitude,
            Longitude = a.Longitude,
            Description = a.Description,
            BuildingOrFloor = a.BuildingOrFloor,
            DeliveryNotes = a.DeliveryNotes,
            IsDefault = a.IsDefault,
            CreationTime = a.CreationTime,
            CreatorId = a.CreatorId,
            LastModificationTime = a.LastModificationTime,
            LastModifierId = a.LastModifierId
        }).ToList();
    }

    [AllowAnonymous]
    public async Task<CustomerAddressDto> AddAddressAsync(Guid customerId, CreateUpdateCustomerAddressDto input)
    {
        if (input.IsDefault)
        {
            var query = await _addressRepository.GetQueryableAsync();
            var existing = await AsyncExecuter.ToListAsync(
                query.Where(a => a.CustomerId == customerId && a.IsDefault)
            );

            foreach (var item in existing)
            {
                item.SetDefault(false);
                await _addressRepository.UpdateAsync(item, autoSave: false);
            }
        }

        var address = new CustomerAddress(
            GuidGenerator.Create(),
            customerId,
            input.Title,
            input.AddressType,
            input.Latitude,
            input.Longitude,
            input.Description,
            input.BuildingOrFloor,
            input.DeliveryNotes,
            input.IsDefault,
            CurrentTenant.Id
        );

        await _addressRepository.InsertAsync(address, autoSave: true);

        return new CustomerAddressDto
        {
            Id = address.Id,
            CustomerId = address.CustomerId,
            Title = address.Title,
            AddressType = address.AddressType,
            Latitude = address.Latitude,
            Longitude = address.Longitude,
            Description = address.Description,
            BuildingOrFloor = address.BuildingOrFloor,
            DeliveryNotes = address.DeliveryNotes,
            IsDefault = address.IsDefault,
            CreationTime = address.CreationTime
        };
    }

    [AllowAnonymous]
    public async Task<CustomerAddressDto> UpdateAddressAsync(Guid addressId, CreateUpdateCustomerAddressDto input)
    {
        var address = await _addressRepository.GetAsync(addressId);

        if (input.IsDefault && !address.IsDefault)
        {
            var query = await _addressRepository.GetQueryableAsync();
            var existing = await AsyncExecuter.ToListAsync(
                query.Where(a => a.CustomerId == address.CustomerId && a.IsDefault)
            );

            foreach (var item in existing)
            {
                item.SetDefault(false);
                await _addressRepository.UpdateAsync(item, autoSave: false);
            }
        }

        address.Update(
            input.Title,
            input.AddressType,
            input.Latitude,
            input.Longitude,
            input.Description,
            input.BuildingOrFloor,
            input.DeliveryNotes,
            input.IsDefault
        );

        await _addressRepository.UpdateAsync(address, autoSave: true);

        return new CustomerAddressDto
        {
            Id = address.Id,
            CustomerId = address.CustomerId,
            Title = address.Title,
            AddressType = address.AddressType,
            Latitude = address.Latitude,
            Longitude = address.Longitude,
            Description = address.Description,
            BuildingOrFloor = address.BuildingOrFloor,
            DeliveryNotes = address.DeliveryNotes,
            IsDefault = address.IsDefault,
            CreationTime = address.CreationTime
        };
    }

    [AllowAnonymous]
    public async Task DeleteAddressAsync(Guid addressId)
    {
        await _addressRepository.DeleteAsync(addressId, autoSave: true);
    }

    [AllowAnonymous]
    public async Task SetDefaultAddressAsync(Guid addressId)
    {
        var address = await _addressRepository.GetAsync(addressId);

        var query = await _addressRepository.GetQueryableAsync();
        var existing = await AsyncExecuter.ToListAsync(
            query.Where(a => a.CustomerId == address.CustomerId)
        );

        foreach (var item in existing)
        {
            item.SetDefault(item.Id == addressId);
            await _addressRepository.UpdateAsync(item, autoSave: false);
        }
    }
}
