using System;
using System.Threading.Tasks;
using LaundrySaaS.Accounting.JournalEntries.Dtos;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;

namespace LaundrySaaS.Accounting.JournalEntries;

[RemoteService(Name = AccountingRemoteServiceConsts.RemoteServiceName)]
[Area(AccountingRemoteServiceConsts.ModuleName)]
[Route("api/accounting/journal-entries")]
public class JournalEntryController : AccountingController, IJournalEntryAppService
{
    private readonly IJournalEntryAppService _journalEntryAppService;

    public JournalEntryController(IJournalEntryAppService journalEntryAppService)
    {
        _journalEntryAppService = journalEntryAppService;
    }

    [HttpGet]
    [Route("{id}")]
    public Task<JournalEntryDto> GetAsync(Guid id)
    {
        return _journalEntryAppService.GetAsync(id);
    }

    [HttpGet]
    public Task<PagedResultDto<JournalEntryDto>> GetListAsync(GetJournalEntriesInput input)
    {
        return _journalEntryAppService.GetListAsync(input);
    }

    [HttpPost]
    [Route("draft")]
    public Task<JournalEntryDto> CreateDraftAsync(CreateJournalEntryDto input)
    {
        return _journalEntryAppService.CreateDraftAsync(input);
    }

    [HttpPut]
    [Route("{id}/draft")]
    public Task<JournalEntryDto> UpdateDraftAsync(Guid id, UpdateJournalEntryDto input)
    {
        return _journalEntryAppService.UpdateDraftAsync(id, input);
    }

    [HttpPost]
    [Route("{id}/post")]
    public Task<JournalEntryDto> PostAsync(Guid id)
    {
        return _journalEntryAppService.PostAsync(id);
    }

    [HttpPost]
    [Route("{id}/cancel")]
    public Task<JournalEntryDto> CancelAsync(Guid id, CancelJournalEntryDto input)
    {
        return _journalEntryAppService.CancelAsync(id, input);
    }

    [HttpDelete]
    [Route("{id}/draft")]
    public Task DeleteDraftAsync(Guid id)
    {
        return _journalEntryAppService.DeleteDraftAsync(id);
    }
}
