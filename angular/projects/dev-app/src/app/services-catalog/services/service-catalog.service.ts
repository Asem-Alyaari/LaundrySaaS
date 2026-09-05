import { Injectable, inject } from '@angular/core';
import { RestService, PagedResultDto, ListResultDto } from '@abp/ng.core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import {
  ServiceItemDto,
  ServiceCategoryDto,
  CreateUpdateServiceItemDto,
  CreateUpdateServiceCategoryDto,
  GetServiceItemsInput,
  GetServiceCategoriesInput,
} from '../models/service-item.models';

@Injectable({
  providedIn: 'root',
})
export class ServiceCatalogService {
  private restService = inject(RestService);
  public apiName = 'LaundrySaaS';

  getCategories(laundryId?: string): Observable<ServiceCategoryDto[]> {
    return this.restService
      .request<{ laundryId?: string }, ListResultDto<ServiceCategoryDto> | ServiceCategoryDto[]>(
        {
          method: 'GET',
          url: '/api/laundries/categories/all',
          params: laundryId ? { laundryId } : undefined,
        },
        {
          apiName: this.apiName,
          skipHandleError: true,
        }
      )
      .pipe(
        map((res: any) => {
          if (res && res.items && Array.isArray(res.items)) {
            return res.items;
          }
          if (Array.isArray(res)) {
            return res;
          }
          return [];
        })
      );
  }

  getCategoriesList(input: GetServiceCategoriesInput): Observable<PagedResultDto<ServiceCategoryDto>> {
    return this.restService.request<GetServiceCategoriesInput, PagedResultDto<ServiceCategoryDto>>(
      {
        method: 'GET',
        url: '/api/laundries/categories',
        params: {
          filter: input.filter,
          laundryId: input.laundryId,
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

  createCategory(input: CreateUpdateServiceCategoryDto): Observable<ServiceCategoryDto> {
    return this.restService.request<CreateUpdateServiceCategoryDto, ServiceCategoryDto>(
      {
        method: 'POST',
        url: '/api/laundries/categories',
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  updateCategory(id: string, input: CreateUpdateServiceCategoryDto): Observable<ServiceCategoryDto> {
    return this.restService.request<CreateUpdateServiceCategoryDto, ServiceCategoryDto>(
      {
        method: 'PUT',
        url: `/api/laundries/categories/${id}`,
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  deleteCategory(id: string): Observable<void> {
    return this.restService.request<void, void>(
      {
        method: 'DELETE',
        url: `/api/laundries/categories/${id}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  getList(input: GetServiceItemsInput): Observable<PagedResultDto<ServiceItemDto>> {
    return this.restService.request<GetServiceItemsInput, PagedResultDto<ServiceItemDto>>(
      {
        method: 'GET',
        url: '/api/laundries/items',
        params: {
          filter: input.filter,
          categoryId: input.categoryId,
          laundryId: input.laundryId,
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

  get(id: string): Observable<ServiceItemDto> {
    return this.restService.request<void, ServiceItemDto>(
      {
        method: 'GET',
        url: `/api/laundries/items/${id}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  create(input: CreateUpdateServiceItemDto): Observable<ServiceItemDto> {
    return this.restService.request<CreateUpdateServiceItemDto, ServiceItemDto>(
      {
        method: 'POST',
        url: '/api/laundries/items',
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  update(id: string, input: CreateUpdateServiceItemDto): Observable<ServiceItemDto> {
    return this.restService.request<CreateUpdateServiceItemDto, ServiceItemDto>(
      {
        method: 'PUT',
        url: `/api/laundries/items/${id}`,
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
        url: `/api/laundries/items/${id}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  /**
   * Import Template Catalog to a specific laundry from backend DB
   */
  importTemplateCatalog(laundryId: string): Observable<ServiceItemDto[]> {
    return this.restService.request<void, ServiceItemDto[]>(
      {
        method: 'POST',
        url: `/api/laundries/items/import-template/${laundryId}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }
}
