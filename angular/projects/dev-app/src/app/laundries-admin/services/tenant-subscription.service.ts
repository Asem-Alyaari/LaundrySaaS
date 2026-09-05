import { Injectable, inject } from '@angular/core';
import { RestService } from '@abp/ng.core';
import { Observable } from 'rxjs';

export interface TenantSubscriptionDto {
  id: string;
  tenantId?: string;
  editionId: string;
  editionName?: string;
  subscriptionCycle: number; // 1: Monthly, 2: Annual
  startDate: string;
  expireDate: string;
  status: number; // 1: Active, 2: Expired, 3: Suspended
  edition?: any;
}

export interface AssignTenantSubscriptionDto {
  tenantId: string;
  editionId: string;
  subscriptionCycle: number;
}

@Injectable({
  providedIn: 'root',
})
export class TenantSubscriptionService {
  private restService = inject(RestService);
  public apiName = 'LaundrySaaS';

  getAll(): Observable<TenantSubscriptionDto[]> {
    return this.restService.request<void, TenantSubscriptionDto[]>(
      {
        method: 'GET',
        url: '/api/saas/tenant-subscriptions',
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  getByTenantId(tenantId: string): Observable<TenantSubscriptionDto> {
    return this.restService.request<void, TenantSubscriptionDto>(
      {
        method: 'GET',
        url: `/api/saas/tenant-subscriptions/by-tenant/${tenantId}`,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }

  assignOrUpdate(input: AssignTenantSubscriptionDto): Observable<TenantSubscriptionDto> {
    return this.restService.request<AssignTenantSubscriptionDto, TenantSubscriptionDto>(
      {
        method: 'POST',
        url: '/api/saas/tenant-subscriptions/assign',
        body: input,
      },
      {
        apiName: this.apiName,
        skipHandleError: true,
      }
    );
  }
}
