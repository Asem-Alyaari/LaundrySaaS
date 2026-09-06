using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.JournalEntries.Dtos;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace LaundrySaaS.Accounting.JournalEntries;

public interface IJournalEntryAppService : IApplicationService
{
    Task<JournalEntryDto> GetAsync(Guid id);

    Task<PagedResultDto<JournalEntryDto>> GetListAsync(GetJournalEntriesInput input);

    Task<JournalEntryDto> CreateDraftAsync(CreateJournalEntryDto input);

    Task<JournalEntryDto> UpdateDraftAsync(Guid id, UpdateJournalEntryDto input);

    Task<JournalEntryDto> PostAsync(Guid id);

    Task<JournalEntryDto> CancelAsync(Guid id, CancelJournalEntryDto input);

    Task DeleteDraftAsync(Guid id);
}
