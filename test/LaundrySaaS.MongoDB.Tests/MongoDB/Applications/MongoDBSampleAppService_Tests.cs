using LaundrySaaS.MongoDB;
using LaundrySaaS.Samples;
using Xunit;

namespace LaundrySaaS.MongoDb.Applications;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleAppService_Tests : SampleAppService_Tests<LaundrySaaSMongoDbTestModule>
{

}
