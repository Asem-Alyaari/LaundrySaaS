using LaundrySaaS.Orders.MongoDB;
using LaundrySaaS.Orders.Samples;
using Xunit;

namespace LaundrySaaS.Orders.MongoDb.Applications;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleAppService_Tests : SampleAppService_Tests<OrdersMongoDbTestModule>
{

}
