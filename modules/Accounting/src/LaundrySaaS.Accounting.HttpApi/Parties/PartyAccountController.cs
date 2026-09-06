using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Parties.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;

namespace LaundrySaaS.Accounting.Parties;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/party-accounts")]
public class PartyAccountController : AccountingController, IPartyAccountAppService
{
    private readonly IPartyAccountAppService _partyAccountAppService;

    public PartyAccountController(IPartyAccountAppService partyAccountAppService)
    {
        _partyAccountAppService = partyAccountAppService;
    }

    [HttpGet]
    [Route("{partyType}/{entityId}")]
    public Task<PartyAccountDto> GetByPartyAsync(PartyType partyType, Guid entityId)
    {
        return _partyAccountAppService.GetByPartyAsync(partyType, entityId);
    }

    [HttpGet]
    [Route("by-type/{partyType}")]
    public Task<List<PartyAccountDto>> GetListByPartyTypeAsync(PartyType partyType)
    {
        return _partyAccountAppService.GetListByPartyTypeAsync(partyType);
    }

    [HttpPost]
    [Route("get-or-create")]
    public Task<PartyAccountDto> GetOrCreatePartyAccountAsync(GetOrCreatePartyAccountInput input)
    {
        return _partyAccountAppService.GetOrCreatePartyAccountAsync(input);
    }
}
