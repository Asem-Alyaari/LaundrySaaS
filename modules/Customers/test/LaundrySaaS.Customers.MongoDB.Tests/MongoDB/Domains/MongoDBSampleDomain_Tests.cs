using LaundrySaaS.Customers.Samples;
using Xunit;

namespace LaundrySaaS.Customers.MongoDB.Domains;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleDomain_Tests : SampleManager_Tests<CustomersMongoDbTestModule>
{

}
