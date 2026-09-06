using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.Accounts;
using LaundrySaaS.Accounting.CostCenters;
using LaundrySaaS.Accounting.JournalEntries.Dtos;
using LaundrySaaS.Accounting.Permissions;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Users;

namespace LaundrySaaS.Accounting.JournalEntries;

[Authorize(AccountingPermissions.JournalEntries.Default)]
public class JournalEntryAppService : AccountingAppService, IJournalEntryAppService
{
    private readonly IJournalEntryRepository _journalEntryRepository;
    private readonly IAccountRepository _accountRepository;
    private readonly ICostCenterRepository _costCenterRepository;
    private readonly JournalEntryManager _journalEntryManager;
    private readonly AccountingApplicationMappers _mapper;

    public JournalEntryAppService(
        IJournalEntryRepository journalEntryRepository,
        IAccountRepository accountRepository,
        ICostCenterRepository costCenterRepository,
        JournalEntryManager journalEntryManager,
        AccountingApplicationMappers mapper)
    {
        _journalEntryRepository = journalEntryRepository;
        _accountRepository = accountRepository;
        _costCenterRepository = costCenterRepository;
        _journalEntryManager = journalEntryManager;
        _mapper = mapper;
    }

    public async Task<JournalEntryDto> GetAsync(Guid id)
    {
        var entry = await _journalEntryRepository.GetWithDetailsAsync(id);
        if (entry == null)
        {
            throw new Volo.Abp.BusinessException(AccountingErrorCodes.AccountNotFound);
        }

        return await MapToDetailedDtoAsync(entry);
    }

    public async Task<PagedResultDto<JournalEntryDto>> GetListAsync(GetJournalEntriesInput input)
    {
        var entries = await _journalEntryRepository.GetListWithDetailsAsync(
            input.StartDate,
            input.EndDate,
            input.Status,
            input.SourceModule,
            input.AccountId,
            input.SkipCount,
            input.MaxResultCount
        );

        var totalCount = await _journalEntryRepository.GetCountAsync();

        var dtoList = new List<JournalEntryDto>();
        foreach (var entry in entries)
        {
            dtoList.Add(await MapToDetailedDtoAsync(entry));
        }

        return new PagedResultDto<JournalEntryDto>(totalCount, dtoList);
    }

    [Authorize(AccountingPermissions.JournalEntries.Create)]
    public async Task<JournalEntryDto> CreateDraftAsync(CreateJournalEntryDto input)
    {
        var entryNumber = await _journalEntryManager.GenerateEntryNumberAsync(input.EntryDate);

        var entry = new JournalEntry(
            GuidGenerator.Create(),
            CurrentTenant.Id,
            entryNumber,
            input.EntryDate,
            input.Description,
            input.EntryType,
            input.SourceModule,
            input.SourceEntityId
        );

        foreach (var lineDto in input.Lines)
        {
            await _journalEntryManager.ValidateLineAccountAsync(lineDto.AccountId);

            entry.AddLine(
                lineDto.AccountId,
                lineDto.Debit,
                lineDto.Credit,
                lineDto.Description,
                lineDto.CostCenterId,
                lineDto.Reference
            );
        }

        await _journalEntryRepository.InsertAsync(entry);
        return await MapToDetailedDtoAsync(entry);
    }

    [Authorize(AccountingPermissions.JournalEntries.Update)]
    public async Task<JournalEntryDto> UpdateDraftAsync(Guid id, UpdateJournalEntryDto input)
    {
        var entry = await _journalEntryRepository.GetWithDetailsAsync(id);
        if (entry == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:EntryNotFound");
        }

        entry.UpdateDetails(input.EntryDate, input.Description);
        entry.ClearLines();

        foreach (var lineDto in input.Lines)
        {
            await _journalEntryManager.ValidateLineAccountAsync(lineDto.AccountId);

            entry.AddLine(
                lineDto.AccountId,
                lineDto.Debit,
                lineDto.Credit,
                lineDto.Description,
                lineDto.CostCenterId,
                lineDto.Reference
            );
        }

        await _journalEntryRepository.UpdateAsync(entry);
        return await MapToDetailedDtoAsync(entry);
    }

    [Authorize(AccountingPermissions.JournalEntries.Post)]
    public async Task<JournalEntryDto> PostAsync(Guid id)
    {
        var entry = await _journalEntryRepository.GetWithDetailsAsync(id);
        if (entry == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:EntryNotFound");
        }

        var currentUserId = CurrentUser.GetId();
        await _journalEntryManager.PostEntryAsync(entry, currentUserId);

        await _journalEntryRepository.UpdateAsync(entry);
        return await MapToDetailedDtoAsync(entry);
    }

    [Authorize(AccountingPermissions.JournalEntries.Cancel)]
    public async Task<JournalEntryDto> CancelAsync(Guid id, CancelJournalEntryDto input)
    {
        var entry = await _journalEntryRepository.GetWithDetailsAsync(id);
        if (entry == null)
        {
            throw new Volo.Abp.BusinessException("Accounting:EntryNotFound");
        }

        entry.Cancel(input.Reason);
        await _journalEntryRepository.UpdateAsync(entry);
        return await MapToDetailedDtoAsync(entry);
    }

    [Authorize(AccountingPermissions.JournalEntries.Create)]
    public async Task DeleteDraftAsync(Guid id)
    {
        var entry = await _journalEntryRepository.GetWithDetailsAsync(id);
        if (entry == null)
        {
            return;
        }

        if (entry.Status != JournalEntryStatus.Draft)
        {
            throw new Volo.Abp.BusinessException(AccountingErrorCodes.JournalEntryAlreadyPosted);
        }

        await _journalEntryRepository.DeleteAsync(entry);
    }

    private async Task<JournalEntryDto> MapToDetailedDtoAsync(JournalEntry entry)
    {
        var dto = _mapper.ToDto(entry);
        dto.Lines = new List<JournalEntryLineDto>();

        foreach (var line in entry.Lines)
        {
            var lineDto = _mapper.ToDto(line);
            var account = await _accountRepository.FindAsync(line.AccountId);
            if (account != null)
            {
                lineDto.AccountCode = account.Code;
                lineDto.AccountName = account.Name;
            }

            if (line.CostCenterId.HasValue)
            {
                var costCenter = await _costCenterRepository.FindAsync(line.CostCenterId.Value);
                if (costCenter != null)
                {
                    lineDto.CostCenterName = costCenter.Name;
                }
            }

            dto.Lines.Add(lineDto);
        }

        return dto;
    }
}
