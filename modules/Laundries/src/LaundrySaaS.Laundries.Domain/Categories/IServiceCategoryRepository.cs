using System;
using Volo.Abp.Domain.Repositories;

namespace LaundrySaaS.Laundries.Categories;

public interface IServiceCategoryRepository : IRepository<ServiceCategory, Guid>
{
}
