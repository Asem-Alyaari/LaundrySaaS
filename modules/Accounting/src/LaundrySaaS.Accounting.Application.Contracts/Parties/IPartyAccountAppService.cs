using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.Parties;

public interface IPartyAccountAppService : IApplicationService
{
    Task<PartyAccountDto> GetByPartyAsync(PartyType partyType, Guid entityId);

    Task<List<PartyAccountDto>> GetListByPartyTypeAsync(PartyType partyType);

    Task<PartyAccountDto> GetOrCreatePartyAccountAsync(GetOrCreatePartyAccountInput input);
}
