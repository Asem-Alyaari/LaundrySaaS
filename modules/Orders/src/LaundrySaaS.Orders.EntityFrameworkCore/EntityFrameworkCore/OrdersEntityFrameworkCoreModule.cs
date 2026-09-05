using LaundrySaaS.Orders.Orders;
using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.Modularity;

namespace LaundrySaaS.Orders.EntityFrameworkCore;

[DependsOn(
    typeof(OrdersDomainModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class OrdersEntityFrameworkCoreModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<OrdersDbContext>(options =>
        {
            options.AddRepository<Order, EfCoreOrderRepository>();
        });
    }
}
