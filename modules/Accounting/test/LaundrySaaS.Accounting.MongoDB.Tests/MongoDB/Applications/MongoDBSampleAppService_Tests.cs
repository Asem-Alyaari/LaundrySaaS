using LaundrySaaS.Accounting.MongoDB;
using LaundrySaaS.Accounting.Samples;
using Xunit;

namespace LaundrySaaS.Accounting.MongoDb.Applications;

[Collection(MongoTestCollection.Name)]
public class MongoDBSampleAppService_Tests : SampleAppService_Tests<AccountingMongoDbTestModule>
{

}
