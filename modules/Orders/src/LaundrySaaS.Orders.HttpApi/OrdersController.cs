using LaundrySaaS.Orders.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace LaundrySaaS.Orders;

public abstract class OrdersController : AbpControllerBase
{
    protected OrdersController()
    {
        LocalizationResource = typeof(OrdersResource);
    }
}
