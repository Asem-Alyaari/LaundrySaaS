using LaundrySaaS.Drivers.MongoDB;
using LaundrySaaS.Drivers.Samples;
using Xunit;

namespace LaundrySaaS.Drivers.MongoDb.Applications;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleAppService_Tests : SampleAppService_Tests<DriversMongoDbTestModule>
{

}
