import { ExtensibleEntityDto, ExtensibleObject, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface EditionDto extends ExtensibleEntityDto<string> {
  displayName: string;
  name?: string;
  price?: number;
  annualPrice?: number;
  planType?: string;
  tenantCount?: number;
  isFree?: boolean;
  concurrencyStamp?: string;
}

export interface EditionCreateDto extends ExtensibleObject {
  displayName: string;
  price?: number;
  annualPrice?: number;
  planType?: string;
  isFree?: boolean;
}

export interface EditionUpdateDto extends ExtensibleObject {
  displayName: string;
  price?: number;
  annualPrice?: number;
  planType?: string;
  isFree?: boolean;
  concurrencyStamp?: string;
}

export interface GetEditionsInput extends PagedAndSortedResultRequestDto {
  filter?: string;
}
