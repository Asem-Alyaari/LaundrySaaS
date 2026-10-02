using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Laundries.Laundries;
using LaundrySaaS.ValueObjects;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Data;
using Volo.Abp.MultiTenancy;

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

    [AllowAnonymous]
    public async Task<List<LaundryDto>> GetNearbyAsync(double lat, double lng, double radiusKm)
    {
        // When searching for nearby laundries, customer searches across all registered laundries in the platform
        using (DataFilter.Disable<IMultiTenant>())
        {
            var query = await Repository.GetQueryableAsync();

            // Only active laundries with coordinates
            var laundries = await AsyncExecuter.ToListAsync(
                query.Where(l => l.IsActive && l.Latitude != null && l.Longitude != null)
            );

            // Filter by Haversine distance in memory
            var nearby = laundries
                .Where(l => HaversineKm(lat, lng, l.Latitude!.Value, l.Longitude!.Value) <= radiusKm)
                .OrderBy(l => HaversineKm(lat, lng, l.Latitude!.Value, l.Longitude!.Value))
                .ToList();

            return nearby.Select(MapToGetOutputDto).ToList();
        }
    }

    private static double HaversineKm(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371.0; // Earth radius in km
        var dLat = ToRad(lat2 - lat1);
        var dLon = ToRad(lon2 - lon1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }

    private static double ToRad(double deg) => deg * (Math.PI / 180.0);

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

