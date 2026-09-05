using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Laundries.Categories;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Laundries.Items;

public class ServiceItemAppService :
    CrudAppService<
        ServiceItem,
        ServiceItemDto,
        Guid,
        GetServiceItemsInput,
        CreateUpdateServiceItemDto>,
    IServiceItemAppService
{
    private readonly IServiceItemRepository _itemRepository;
    private readonly IServiceCategoryRepository _categoryRepository;

    public ServiceItemAppService(
        IServiceItemRepository repository,
        IServiceCategoryRepository categoryRepository)
        : base(repository)
    {
        _itemRepository = repository;
        _categoryRepository = categoryRepository;
        ObjectMapperContext = typeof(LaundriesApplicationModule);
    }

    protected override async Task<IQueryable<ServiceItem>> CreateFilteredQueryAsync(GetServiceItemsInput input)
    {
        var query = await base.CreateFilteredQueryAsync(input);

        if (input.LaundryId.HasValue && input.LaundryId.Value != Guid.Empty)
        {
            query = query.Where(i => i.LaundryId == input.LaundryId.Value);
        }

        if (input.CategoryId.HasValue && input.CategoryId.Value != Guid.Empty)
        {
            query = query.Where(i => i.CategoryId == input.CategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            query = query.Where(i => i.Name.Contains(input.Filter) ||
                                     (i.Description != null && i.Description.Contains(input.Filter)));
        }

        return query;
    }

    public async Task<List<ServiceItemDto>> ImportTemplateCatalogAsync(Guid laundryId)
    {
        var categories = await _categoryRepository.GetListAsync();
        if (categories.Count == 0)
        {
            // Seed basic categories if not exists
            var defaultCat1 = new ServiceCategory(GuidGenerator.Create(), "الملابس والزي الرسمي", laundryId, "skin", "blue", 1, CurrentTenant.Id);
            var defaultCat2 = new ServiceCategory(GuidGenerator.Create(), "التنظيف الجاف الفاخر (Dry Clean)", laundryId, "thunderbolt", "purple", 2, CurrentTenant.Id);
            var defaultCat3 = new ServiceCategory(GuidGenerator.Create(), "المفروشات والستائر", laundryId, "home", "cyan", 3, CurrentTenant.Id);
            var defaultCat4 = new ServiceCategory(GuidGenerator.Create(), "السجاد والموكيت", laundryId, "appstore", "gold", 4, CurrentTenant.Id);
            var defaultCat5 = new ServiceCategory(GuidGenerator.Create(), "الغسيل بالكيلو (عناية يومية)", laundryId, "shopping", "green", 5, CurrentTenant.Id);

            await _categoryRepository.InsertManyAsync(new[] { defaultCat1, defaultCat2, defaultCat3, defaultCat4, defaultCat5 });
            categories = new List<ServiceCategory> { defaultCat1, defaultCat2, defaultCat3, defaultCat4, defaultCat5 };
        }

        var catClothes = categories.FirstOrDefault(c => c.Name.Contains("الملابس"))?.Id ?? categories[0].Id;
        var catDry = categories.FirstOrDefault(c => c.Name.Contains("الجاف"))?.Id ?? categories[0].Id;
        var catBedding = categories.FirstOrDefault(c => c.Name.Contains("المفروشات"))?.Id ?? categories[0].Id;
        var catCarpets = categories.FirstOrDefault(c => c.Name.Contains("السجاد"))?.Id ?? categories[0].Id;
        var catKg = categories.FirstOrDefault(c => c.Name.Contains("كيلو"))?.Id ?? categories[0].Id;

        var templateItems = new List<ServiceItem>
        {
            new ServiceItem(GuidGenerator.Create(), "ثوب رجالي سعودي (غسيل وكي بخار)", 12, catClothes, laundryId, true, "قطعة", 24, "غسيل احترافي مع النشا والتكييف بالبخار والتغليف الفردي الفاخر", "skin", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "شماغ / غترة (كي ونشا خاص)", 6, catClothes, laundryId, true, "قطعة", 12, "كي بالبخار وضبط أطراف الشماغ مع درجة النشا المطلوبة", "skin", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "بدلة رجالية رسمية 2 قطعة (تنظيف جاف)", 35, catDry, laundryId, true, "طقم", 48, "تنظيف جاف متقدم بمركبات آمنة للأنسجة مع إزالة البقع والكي الرأسي", "thunderbolt", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "فستان سهرة / مناسبات (عناية خاصة)", 85, catDry, laundryId, true, "قطعة", 48, "عناية فائقة بالأقمشة الحساسة والخرز والتطريز اليدوي والتجفيف الآمن", "thunderbolt", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "عباية نسائية مع الطرحة (غسيل وكي بخار)", 18, catClothes, laundryId, true, "قطعة", 24, "غسيل مخصص للأقمشة السوداء لمنع بهتان اللون مع تعطير خفيف", "skin", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "لحاف سرير كينج / مفرش شتوي (غسيل وتعقيم)", 45, catBedding, laundryId, true, "قطعة", 48, "غسيل عميق في غسالات سعة كبيرة مع مواد تعقيم مضادة للبكتيريا والروائح", "home", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "ستائر شيفون / قماش مع الفك والتركيب)", 25, catBedding, laundryId, true, "متر", 72, "تنظيف ستائر وإزالة الغبار والكي التجعيدي التناسقي", "home", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "سجاد تركي / إيراني فاخر (غسيل وتطهير بالمتر)", 20, catCarpets, laundryId, true, "متر مربع", 72, "فرك دوار آلي بشامبو مخصص للمحافظة على وبرة السجاد ولمعانه", "appstore", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "غسيل وتنشيف عادي بالكيلو (Wash & Fold)", 8, catKg, laundryId, true, "كيلو", 24, "غسيل وتجفيف وصفط الملابس المنزلية والقطنيات والملابس الداخلية", "shopping", CurrentTenant.Id),
            new ServiceItem(GuidGenerator.Create(), "حذاء رياضي / جلد (تنظيف وتبييض وتعقيم)", 25, catClothes, laundryId, true, "زوج", 36, "تنظيف عميق وإزالة الاصفرار والأوساخ وتعقيم النعل والفرش الداخلي", "skin", CurrentTenant.Id)
        };

        await _itemRepository.InsertManyAsync(templateItems);
        return templateItems.Select(MapToGetOutputDto).ToList();
    }

    protected override ServiceItemDto MapToGetOutputDto(ServiceItem entity)
    {
        return new ServiceItemDto
        {
            Id = entity.Id,
            Name = entity.Name,
            Price = entity.Price,
            CategoryId = entity.CategoryId,
            LaundryId = entity.LaundryId,
            IsActive = entity.IsActive,
            Unit = entity.Unit,
            DurationHours = entity.DurationHours,
            Description = entity.Description,
            Icon = entity.Icon,
            CreationTime = entity.CreationTime,
            CreatorId = entity.CreatorId,
            LastModificationTime = entity.LastModificationTime,
            LastModifierId = entity.LastModifierId
        };
    }

    protected override ServiceItemDto MapToGetListOutputDto(ServiceItem entity)
    {
        return MapToGetOutputDto(entity);
    }

    protected override ServiceItem MapToEntity(CreateUpdateServiceItemDto createInput)
    {
        return new ServiceItem(
            GuidGenerator.Create(),
            createInput.Name,
            createInput.Price,
            createInput.CategoryId,
            createInput.LaundryId,
            createInput.IsActive,
            createInput.Unit,
            createInput.DurationHours,
            createInput.Description,
            createInput.Icon,
            CurrentTenant.Id
        );
    }

    protected override void MapToEntity(CreateUpdateServiceItemDto updateInput, ServiceItem entity)
    {
        entity.Update(
            updateInput.Name,
            updateInput.Price,
            updateInput.CategoryId,
            updateInput.IsActive,
            updateInput.Unit,
            updateInput.DurationHours,
            updateInput.Description,
            updateInput.Icon
        );
    }
}
