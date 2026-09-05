import { Routes } from '@angular/router';

export const editionsAdminRoutes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    loadComponent: () => import('./editions-admin.component').then(m => m.EditionsAdminComponent),
  },
];
