using LaundrySaaS.Customers.MongoDB;
using LaundrySaaS.Customers.Samples;
using Xunit;

namespace LaundrySaaS.Customers.MongoDb.Applications;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleAppService_Tests : SampleAppService_Tests<CustomersMongoDbTestModule>
{

}
