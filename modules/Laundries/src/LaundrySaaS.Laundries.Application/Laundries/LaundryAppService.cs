using System;
using LaundrySaaS.Laundries.Laundries;
using LaundrySaaS.ValueObjects;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Laundries.Laundries;

public class LaundryAppService :
    CrudAppService<
        Laundry,
        LaundryDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateLaundryDto>,
    ILaundryAppService
{
    private readonly ILaundryRepository _laundryRepository;

    public LaundryAppService(ILaundryRepository repository)
        : base(repository)
    {
        _laundryRepository = repository;
    }

    protected override LaundryDto MapToGetOutputDto(Laundry entity)
    {
        return new LaundryDto
        {
            Id = entity.Id,
            Name = entity.Name,
            PhoneNumber = entity.PhoneNumber,
            Address = new AddressDto
            {
                City = entity.Address.City,
                District = entity.Address.District,
                Street = entity.Address.Street,
                BuildingNumber = entity.Address.BuildingNumber
            },
            Latitude = entity.Latitude,
            Longitude = entity.Longitude,
            IsActive = entity.IsActive,
            CreationTime = entity.CreationTime,
            CreatorId = entity.CreatorId,
            LastModificationTime = entity.LastModificationTime,
            LastModifierId = entity.LastModifierId
        };
    }

    protected override LaundryDto MapToGetListOutputDto(Laundry entity)
    {
        return MapToGetOutputDto(entity);
    }

    protected override Laundry MapToEntity(CreateUpdateLaundryDto createInput)
    {
        var address = new Address(
            createInput.Address.City,
            createInput.Address.District,
            createInput.Address.Street,
            createInput.Address.BuildingNumber
        );

        return new Laundry(
            GuidGenerator.Create(),
            CurrentTenant.Id,
            createInput.Name,
            createInput.PhoneNumber,
            address,
            createInput.Latitude,
            createInput.Longitude,
            createInput.IsActive
        );
    }

    protected override void MapToEntity(CreateUpdateLaundryDto updateInput, Laundry entity)
    {
        var address = new Address(
            updateInput.Address.City,
            updateInput.Address.District,
            updateInput.Address.Street,
            updateInput.Address.BuildingNumber
        );

        entity.Update(
            updateInput.Name,
            updateInput.PhoneNumber,
            address,
            updateInput.Latitude,
            updateInput.Longitude,
            updateInput.IsActive
        );
    }
}
