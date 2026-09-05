using LaundrySaaS.Drivers.Samples;
using Xunit;

namespace LaundrySaaS.Drivers.MongoDB.Domains;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleDomain_Tests : SampleManager_Tests<DriversMongoDbTestModule>
{

}
