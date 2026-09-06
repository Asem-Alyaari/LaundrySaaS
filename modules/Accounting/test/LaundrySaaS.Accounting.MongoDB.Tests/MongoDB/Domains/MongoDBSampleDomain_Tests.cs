using LaundrySaaS.Accounting.Samples;
using Xunit;

namespace LaundrySaaS.Accounting.MongoDB.Domains;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleDomain_Tests : SampleManager_Tests<AccountingMongoDbTestModule>
{

}
