using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.Parties.Dtos;
using Volo.Abp;

namespace LaundrySaaS.Accounting.Parties;

public class PartyAccountAppService : AccountingAppService, IPartyAccountAppService
{
    private readonly IPartyAccountRepository _partyAccountRepository;
    private readonly IAccountRepository _accountRepository;
    private readonly PartyAccountManager _partyAccountManager;
    private readonly AccountingApplicationMappers _mapper;

    public PartyAccountAppService(
        IPartyAccountRepository partyAccountRepository,
        IAccountRepository accountRepository,
        PartyAccountManager partyAccountManager,
        AccountingApplicationMappers mapper)
    {
        _partyAccountRepository = partyAccountRepository;
        _accountRepository = accountRepository;
        _partyAccountManager = partyAccountManager;
        _mapper = mapper;
    }

    public async Task<PartyAccountDto> GetByPartyAsync(PartyType partyType, Guid entityId)
    {
        var partyAccount = await _partyAccountRepository.FindByPartyAsync(partyType, entityId);
        if (partyAccount == null)
        {
            throw new BusinessException("Accounting:PartyAccountNotFound");
        }

        return await MapToDtoAsync(partyAccount);
    }

    public async Task<List<PartyAccountDto>> GetListByPartyTypeAsync(PartyType partyType)
    {
        var list = await _partyAccountRepository.GetListByPartyTypeAsync(partyType);
        var dtoList = new List<PartyAccountDto>();
        foreach (var item in list)
        {
            dtoList.Add(await MapToDtoAsync(item));
        }
        return dtoList;
    }

    public async Task<PartyAccountDto> GetOrCreatePartyAccountAsync(GetOrCreatePartyAccountInput input)
    {
        var account = await _partyAccountManager.GetOrCreateAccountAsync(
            input.PartyType,
            input.EntityId,
            input.PartyName,
            input.TenantId
        );

        var partyAccount = await _partyAccountRepository.FindByPartyAsync(input.PartyType, input.EntityId);
        if (partyAccount != null)
        {
            var dto = _mapper.ToDto(partyAccount);
            dto.AccountCode = account.Code;
            return dto;
        }

        return new PartyAccountDto
        {
            AccountId = account.Id,
            AccountCode = account.Code,
            EntityId = input.EntityId,
            PartyType = input.PartyType,
            PartyName = input.PartyName
        };
    }

    private async Task<PartyAccountDto> MapToDtoAsync(PartyAccount partyAccount)
    {
        var dto = _mapper.ToDto(partyAccount);
        var account = await _accountRepository.FindAsync(partyAccount.AccountId);
        if (account != null)
        {
            dto.AccountCode = account.Code;
        }
        return dto;
    }
}
