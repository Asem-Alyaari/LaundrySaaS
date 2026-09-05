using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Subscriptions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Editions;

public class EditionAppService :
    CrudAppService<
        Edition,
        EditionDto,
        Guid,
        GetEditionsInput,
        CreateEditionDto,
        UpdateEditionDto>,
    IEditionAppService
{
    private readonly IRepository<TenantSubscription, Guid> _subscriptionRepository;

    public EditionAppService(
        IRepository<Edition, Guid> repository,
        IRepository<TenantSubscription, Guid> subscriptionRepository)
        : base(repository)
    {
        _subscriptionRepository = subscriptionRepository;
    }

    protected override async Task<IQueryable<Edition>> CreateFilteredQueryAsync(GetEditionsInput input)
    {
        var query = await base.CreateFilteredQueryAsync(input);

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            query = query.Where(e => e.DisplayName.Contains(input.Filter));
        }

        return query;
    }

    /// <summary>
    /// Manual mapping: Edition entity → EditionDto (bypasses IObjectMapper / Mapperly)
    /// </summary>
    protected override EditionDto MapToGetOutputDto(Edition entity)
    {
        return MapEditionToDto(entity);
    }

    /// <summary>
    /// Manual mapping: Edition entity → EditionDto for list results
    /// </summary>
    protected override EditionDto MapToGetListOutputDto(Edition entity)
    {
        return MapEditionToDto(entity);
    }

    protected override Edition MapToEntity(CreateEditionDto createInput)
    {
        return new Edition(
            GuidGenerator.Create(),
            createInput.DisplayName,
            createInput.Price,
            createInput.AnnualPrice,
            createInput.PlanType,
            createInput.IsFree
        );
    }

    protected override void MapToEntity(UpdateEditionDto updateInput, Edition entity)
    {
        entity.Update(
            updateInput.DisplayName,
            updateInput.Price,
            updateInput.AnnualPrice,
            updateInput.PlanType,
            updateInput.IsFree
        );
    }

    public override async Task<PagedResultDto<EditionDto>> GetListAsync(GetEditionsInput input)
    {
        var result = await base.GetListAsync(input);

        if (result.Items.Count > 0)
        {
            var editionIds = result.Items.Select(x => x.Id).ToList();
            var query = (await _subscriptionRepository.GetQueryableAsync())
                .Where(s => editionIds.Contains(s.EditionId))
                .GroupBy(s => s.EditionId)
                .Select(g => new { EditionId = g.Key, Count = g.Count() });

            var subscriptions = await AsyncExecuter.ToListAsync(query);
            var countDict = subscriptions.ToDictionary(k => k.EditionId, v => v.Count);

            foreach (var item in result.Items)
            {
                if (countDict.TryGetValue(item.Id, out var count))
                {
                    item.TenantCount = count;
                }
            }
        }

        return result;
    }

    private static EditionDto MapEditionToDto(Edition entity)
    {
        return new EditionDto
        {
            Id = entity.Id,
            DisplayName = entity.DisplayName,
            Price = entity.Price,
            AnnualPrice = entity.AnnualPrice,
            PlanType = entity.PlanType,
            IsFree = entity.IsFree,
            CreationTime = entity.CreationTime,
            CreatorId = entity.CreatorId,
            LastModificationTime = entity.LastModificationTime,
            LastModifierId = entity.LastModifierId,
        };
    }
}
