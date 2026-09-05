import { Routes } from '@angular/router';

export const laundriesAdminRoutes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    loadComponent: () => import('./laundries-admin.component').then(m => m.LaundriesAdminComponent),
  },
];
