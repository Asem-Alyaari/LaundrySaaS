import { ExtensibleEntityDto, ExtensibleObject, PagedAndSortedResultRequestDto } from '@abp/ng.core';

export interface ServiceCategoryDto extends ExtensibleEntityDto<string> {
  name: string;
  icon?: string;
  color?: string;
  displayOrder?: number;
  itemCount?: number;
  laundryId?: string;
}

export interface CreateUpdateServiceCategoryDto extends ExtensibleObject {
  name: string;
  laundryId?: string;
  icon?: string;
  color?: string;
  displayOrder?: number;
}

export interface ServiceItemDto extends ExtensibleEntityDto<string> {
  name: string;
  price: number;
  categoryId: string;
  categoryName?: string;
  laundryId?: string;
  laundryName?: string;
  unit?: string;
  durationHours?: number;
  description?: string;
  isActive: boolean;
  icon?: string;
}

export interface CreateUpdateServiceItemDto extends ExtensibleObject {
  name: string;
  price: number;
  categoryId: string;
  laundryId?: string;
  unit?: string;
  durationHours?: number;
  description?: string;
  isActive: boolean;
}

export interface GetServiceItemsInput extends PagedAndSortedResultRequestDto {
  filter?: string;
  categoryId?: string;
  laundryId?: string;
}

export interface GetServiceCategoriesInput extends PagedAndSortedResultRequestDto {
  filter?: string;
  laundryId?: string;
}
