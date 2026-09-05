using LaundrySaaS.Orders.Samples;
using Xunit;

namespace LaundrySaaS.Orders.MongoDB.Domains;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleDomain_Tests : SampleManager_Tests<OrdersMongoDbTestModule>
{

}
