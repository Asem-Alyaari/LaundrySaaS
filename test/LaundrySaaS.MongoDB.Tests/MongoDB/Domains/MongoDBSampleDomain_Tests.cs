using LaundrySaaS.Samples;
using Xunit;

namespace LaundrySaaS.MongoDB.Domains;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleDomain_Tests : SampleManager_Tests<LaundrySaaSMongoDbTestModule>
{

}
