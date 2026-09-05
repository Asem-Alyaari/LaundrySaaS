using System;
using System.Threading.Tasks;
using LaundrySaaS.Editions;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace LaundrySaaS.Data;

public class LaundrySaaSEditionsDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<Edition, Guid> _editionRepository;
    private readonly IGuidGenerator _guidGenerator;

    public LaundrySaaSEditionsDataSeedContributor(
        IRepository<Edition, Guid> editionRepository,
        IGuidGenerator guidGenerator)
    {
        _editionRepository = editionRepository;
        _guidGenerator = guidGenerator;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _editionRepository.GetCountAsync() > 0)
        {
            return;
        }

        await _editionRepository.InsertManyAsync(new[]
        {
            new Edition(_guidGenerator.Create(), "الباقة الأساسية (Starter)", 199m, 1990m, PlanType.Standard, false),
            new Edition(_guidGenerator.Create(), "الباقة المتقدمة (Professional)", 499m, 4990m, PlanType.Professional, false),
            new Edition(_guidGenerator.Create(), "باقة المؤسسات وسلاسل المغاسل (Enterprise)", 999m, 9990m, PlanType.Enterprise, false),
            new Edition(_guidGenerator.Create(), "الباقة التجريبية المجانية (Free Trial 14 Days)", 0m, 0m, PlanType.Free, true)
        }, autoSave: true);
    }
}
