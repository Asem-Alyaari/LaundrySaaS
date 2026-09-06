using System;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Drivers.Drivers;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Drivers.Drivers;

public class DriverAppService :
    CrudAppService<
        Driver,
        DriverDto,
        Guid,
        GetDriversInputDto,
        CreateUpdateDriverDto>,
    IDriverAppService
{
    public DriverAppService(IRepository<Driver, Guid> repository)
        : base(repository)
    {
        ObjectMapperContext = typeof(DriversApplicationModule);
    }

    protected override DriverDto MapToGetOutputDto(Driver entity)
    {
        return new DriverDto
        {
            Id = entity.Id,
            TenantId = entity.TenantId,
            LaundryId = entity.LaundryId,
            FullName = entity.FullName,
            PhoneNumber = entity.PhoneNumber,
            VehicleInfo = entity.VehicleInfo,
            IsAvailable = entity.IsAvailable,
            CreationTime = entity.CreationTime,
            CreatorId = entity.CreatorId,
            LastModificationTime = entity.LastModificationTime,
            LastModifierId = entity.LastModifierId
        };
    }

    protected override async Task<IQueryable<Driver>> CreateFilteredQueryAsync(GetDriversInputDto input)
    {
        var query = await base.CreateFilteredQueryAsync(input);

        if (input.LaundryId.HasValue)
        {
            query = query.Where(d => d.LaundryId == input.LaundryId.Value);
        }

        if (input.IsAvailable.HasValue)
        {
            query = query.Where(d => d.IsAvailable == input.IsAvailable.Value);
        }

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            var filter = input.Filter.Trim();
            query = query.Where(d =>
                d.FullName.Contains(filter) ||
                d.PhoneNumber.Contains(filter) ||
                d.VehicleInfo.Contains(filter));
        }

        return query;
    }

    protected override Driver MapToEntity(CreateUpdateDriverDto createInput)
    {
        return new Driver(
            GuidGenerator.Create(),
            createInput.FullName,
            createInput.PhoneNumber,
            createInput.VehicleInfo,
            createInput.IsAvailable,
            createInput.LaundryId,
            CurrentTenant.Id
        );
    }

    protected override void MapToEntity(CreateUpdateDriverDto updateInput, Driver entity)
    {
        entity.Update(
            updateInput.FullName,
            updateInput.PhoneNumber,
            updateInput.VehicleInfo,
            updateInput.IsAvailable,
            updateInput.LaundryId
        );
    }

    public async Task SetAvailabilityAsync(Guid id, bool isAvailable)
    {
        var driver = await Repository.GetAsync(id);
        driver.SetAvailability(isAvailable);
        await Repository.UpdateAsync(driver, autoSave: true);
    }
}
