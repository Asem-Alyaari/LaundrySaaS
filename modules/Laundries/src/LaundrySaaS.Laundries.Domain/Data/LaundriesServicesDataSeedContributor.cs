using System;
using System.Threading.Tasks;
using LaundrySaaS.Laundries.Categories;
using LaundrySaaS.Laundries.Items;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace LaundrySaaS.Laundries.Data;

public class LaundriesServicesDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<ServiceCategory, Guid> _categoryRepository;
    private readonly IRepository<ServiceItem, Guid> _itemRepository;
    private readonly IGuidGenerator _guidGenerator;

    public LaundriesServicesDataSeedContributor(
        IRepository<ServiceCategory, Guid> categoryRepository,
        IRepository<ServiceItem, Guid> itemRepository,
        IGuidGenerator guidGenerator)
    {
        _categoryRepository = categoryRepository;
        _itemRepository = itemRepository;
        _guidGenerator = guidGenerator;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _categoryRepository.GetCountAsync() > 0)
        {
            return;
        }

        var catClothesId = _guidGenerator.Create();
        var catDryCleanId = _guidGenerator.Create();
        var catBeddingId = _guidGenerator.Create();
        var catCarpetsId = _guidGenerator.Create();
        var catKgId = _guidGenerator.Create();

        var categories = new[]
        {
            new ServiceCategory(catClothesId, "الملابس والزي الرسمي", Guid.Empty, "skin", "blue", 1),
            new ServiceCategory(catDryCleanId, "التنظيف الجاف الفاخر (Dry Clean)", Guid.Empty, "thunderbolt", "purple", 2),
            new ServiceCategory(catBeddingId, "المفروشات والستائر", Guid.Empty, "home", "cyan", 3),
            new ServiceCategory(catCarpetsId, "السجاد والموكيت", Guid.Empty, "appstore", "gold", 4),
            new ServiceCategory(catKgId, "الغسيل بالكيلو (عناية يومية)", Guid.Empty, "shopping", "green", 5)
        };

        await _categoryRepository.InsertManyAsync(categories, autoSave: true);

        if (await _itemRepository.GetCountAsync() == 0)
        {
            var items = new[]
            {
                new ServiceItem(_guidGenerator.Create(), "ثوب رجالي سعودي (غسيل وكي بخار)", 12m, catClothesId, Guid.Empty, true, "قطعة", 24, "غسيل احترافي مع النشا والتكييف بالبخار والتغليف الفردي الفاخر", "skin"),
                new ServiceItem(_guidGenerator.Create(), "شماغ / غترة (كي ونشا خاص)", 6m, catClothesId, Guid.Empty, true, "قطعة", 12, "كي بالبخار وضبط أطراف الشماغ مع درجة النشا المطلوبة", "skin"),
                new ServiceItem(_guidGenerator.Create(), "بدلة رجالية رسمية 2 قطعة (تنظيف جاف)", 35m, catDryCleanId, Guid.Empty, true, "طقم", 48, "تنظيف جاف متقدم بمركبات آمنة للأنسجة مع إزالة البقع والكي الرأسي", "thunderbolt"),
                new ServiceItem(_guidGenerator.Create(), "فستان سهرة / مناسبات (عناية خاصة)", 85m, catDryCleanId, Guid.Empty, true, "قطعة", 48, "عناية فائقة بالأقمشة الحساسة والخرز والتطريز اليدوي والتجفيف الآمن", "thunderbolt"),
                new ServiceItem(_guidGenerator.Create(), "عباية نسائية مع الطرحة (غسيل وكي بخار)", 18m, catClothesId, Guid.Empty, true, "قطعة", 24, "غسيل مخصص للأقمشة السوداء لمنع بهتان اللون مع تعطير خفيف", "skin"),
                new ServiceItem(_guidGenerator.Create(), "لحاف سرير كينج / مفرش شتوي (غسيل وتعقيم)", 45m, catBeddingId, Guid.Empty, true, "قطعة", 48, "غسيل عميق في غسالات سعة كبيرة مع مواد تعقيم مضادة للبكتيريا والروائح", "home"),
                new ServiceItem(_guidGenerator.Create(), "ستائر شيفون / قماش مع الفك والتركيب", 25m, catBeddingId, Guid.Empty, true, "متر", 72, "تنظيف ستائر وإزالة الغبار والكي التجعيدي التناسقي", "home"),
                new ServiceItem(_guidGenerator.Create(), "سجاد تركي / إيراني فاخر (غسيل وتطهير بالمتر)", 20m, catCarpetsId, Guid.Empty, true, "متر مربع", 72, "فرك دوار آلي بشامبو مخصص للمحافظة على وبرة السجاد ولمعانه", "appstore"),
                new ServiceItem(_guidGenerator.Create(), "غسيل وتنشيف عادي بالكيلو (Wash & Fold)", 8m, catKgId, Guid.Empty, true, "كيلو", 24, "غسيل وتجفيف وصفط الملابس المنزلية والقطنيات والملابس الداخلية", "shopping"),
                new ServiceItem(_guidGenerator.Create(), "حذاء رياضي / جلد (تنظيف وتبييض وتعقيم)", 25m, catClothesId, Guid.Empty, true, "زوج", 36, "تنظيف عميق وإزالة الاصفرار والأوساخ وتعقيم النعل والفرش الداخلي", "skin")
            };

            await _itemRepository.InsertManyAsync(items, autoSave: true);
        }
    }
}
