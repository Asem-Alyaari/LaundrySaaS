import { Routes } from '@angular/router';
import { authGuard } from '@abp/ng.core';
import { AdminLayoutComponent } from './layout/admin-layout/admin-layout.component';

export const appRoutes: Routes = [
  {
    path: '',
    component: AdminLayoutComponent,
    canActivate: [authGuard],
    children: [
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full',
      },
      {
        path: 'dashboard',
        loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes),
      },
      {
        path: 'laundries-admin',
        loadChildren: () => import('./laundries-admin/laundries-admin.routes').then(m => m.laundriesAdminRoutes),
      },
      {
        path: 'laundries',
        loadChildren: () => import('./laundries-admin/laundries-admin.routes').then(m => m.laundriesAdminRoutes),
      },
      {
        path: 'editions',
        loadChildren: () => import('./editions-admin/editions-admin.routes').then(m => m.editionsAdminRoutes),
      },
      {
        path: 'editions-admin',
        loadChildren: () => import('./editions-admin/editions-admin.routes').then(m => m.editionsAdminRoutes),
      },
      {
        path: 'services',
        loadChildren: () => import('./services-catalog/services-catalog.routes').then(m => m.servicesCatalogRoutes),
      },
      {
        path: 'services-catalog',
        loadChildren: () => import('./services-catalog/services-catalog.routes').then(m => m.servicesCatalogRoutes),
      },
      {
        path: 'customers',
        loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes),
      },
      {
        path: 'drivers',
        loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes),
      },
      {
        path: 'orders',
        loadChildren: () => import('./home/home.routes').then(m => m.homeRoutes),
      },
      {
        path: 'account',
        loadChildren: () => import('@abp/ng.account').then(m => m.createRoutes()),
      },
      {
        path: 'identity',
        loadChildren: () => import('@abp/ng.identity').then(m => m.createRoutes()),
      },
      {
        path: 'tenant-management',
        loadChildren: () => import('./laundries-admin/laundries-admin.routes').then(m => m.laundriesAdminRoutes),
      },
      {
        path: 'setting-management',
        loadChildren: () => import('@abp/ng.setting-management').then(m => m.createRoutes()),
      },
      {
        path: 'laundry-saa-s',
        loadChildren: () => import('@laundry-saa-s').then(m => m.laundrySaaSRoutes),
      },
    ],
  },
];
