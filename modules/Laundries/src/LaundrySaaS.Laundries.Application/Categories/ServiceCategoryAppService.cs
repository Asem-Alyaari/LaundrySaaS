using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Laundries.Categories;

public class ServiceCategoryAppService :
    CrudAppService<
        ServiceCategory,
        ServiceCategoryDto,
        Guid,
        GetServiceCategoriesInput,
        CreateUpdateServiceCategoryDto>,
    IServiceCategoryAppService
{
    private readonly IServiceCategoryRepository _categoryRepository;

    public ServiceCategoryAppService(IServiceCategoryRepository repository)
        : base(repository)
    {
        _categoryRepository = repository;
        ObjectMapperContext = typeof(LaundriesApplicationModule);
    }

    protected override async Task<IQueryable<ServiceCategory>> CreateFilteredQueryAsync(GetServiceCategoriesInput input)
    {
        var query = await base.CreateFilteredQueryAsync(input);

        if (input.LaundryId.HasValue && input.LaundryId.Value != Guid.Empty)
        {
            query = query.Where(c => c.LaundryId == input.LaundryId.Value || c.LaundryId == Guid.Empty);
        }

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            query = query.Where(c => c.Name.Contains(input.Filter));
        }

        return query.OrderBy(c => c.DisplayOrder).ThenBy(c => c.Name);
    }

    public async Task<ListResultDto<ServiceCategoryDto>> GetAllAsync(Guid? laundryId = null)
    {
        var query = await _categoryRepository.GetQueryableAsync();

        if (laundryId.HasValue && laundryId.Value != Guid.Empty)
        {
            query = query.Where(c => c.LaundryId == laundryId.Value || c.LaundryId == Guid.Empty);
        }

        var categories = await AsyncExecuter.ToListAsync(query.OrderBy(c => c.DisplayOrder).ThenBy(c => c.Name));
        return new ListResultDto<ServiceCategoryDto>(categories.Select(MapToGetOutputDto).ToList());
    }

    protected override ServiceCategoryDto MapToGetOutputDto(ServiceCategory entity)
    {
        return new ServiceCategoryDto
        {
            Id = entity.Id,
            Name = entity.Name,
            LaundryId = entity.LaundryId,
            Icon = entity.Icon,
            Color = entity.Color,
            DisplayOrder = entity.DisplayOrder,
            CreationTime = entity.CreationTime,
            CreatorId = entity.CreatorId,
            LastModificationTime = entity.LastModificationTime,
            LastModifierId = entity.LastModifierId
        };
    }

    protected override ServiceCategoryDto MapToGetListOutputDto(ServiceCategory entity)
    {
        return MapToGetOutputDto(entity);
    }

    protected override ServiceCategory MapToEntity(CreateUpdateServiceCategoryDto createInput)
    {
        return new ServiceCategory(
            GuidGenerator.Create(),
            createInput.Name,
            createInput.LaundryId ?? Guid.Empty,
            createInput.Icon,
            createInput.Color,
            createInput.DisplayOrder,
            CurrentTenant.Id
        );
    }

    protected override void MapToEntity(CreateUpdateServiceCategoryDto updateInput, ServiceCategory entity)
    {
        entity.Update(
            updateInput.Name,
            updateInput.Icon,
            updateInput.Color,
            updateInput.DisplayOrder
        );
    }
}
