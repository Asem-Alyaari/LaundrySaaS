import { Injectable, inject } from '@angular/core';
import { RestService, PagedResultDto } from '@abp/ng.core';
import { Observable } from 'rxjs';
import { EditionDto, EditionCreateDto, EditionUpdateDto, GetEditionsInput } from '../models/edition.models';

@Injectable({
  providedIn: 'root',
})
export class EditionService {
  private restService = inject(RestService);
  public apiName = 'LaundrySaaS';

  getList(input: GetEditionsInput): Observable<PagedResultDto<EditionDto>> {
    return this.restService.request<GetEditionsInput, PagedResultDto<EditionDto>>(
      {
        method: 'GET',
        url: '/api/saas/editions',
        params: {
          filter: input.filter,
          sorting: input.sorting,
          skipCount: input.skipCount,
          maxResultCount: input.maxResultCount,
        },
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  get(id: string): Observable<EditionDto> {
    return this.restService.request<void, EditionDto>(
      {
        method: 'GET',
        url: `/api/saas/editions/${id}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  create(input: EditionCreateDto): Observable<EditionDto> {
    return this.restService.request<EditionCreateDto, EditionDto>(
      {
        method: 'POST',
        url: '/api/saas/editions',
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  update(id: string, input: EditionUpdateDto): Observable<EditionDto> {
    return this.restService.request<EditionUpdateDto, EditionDto>(
      {
        method: 'PUT',
        url: `/api/saas/editions/${id}`,
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  delete(id: string): Observable<void> {
    return this.restService.request<void, void>(
      {
        method: 'DELETE',
        url: `/api/saas/editions/${id}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }
}
