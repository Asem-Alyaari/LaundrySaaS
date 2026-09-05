import { Routes } from '@angular/router';

export const servicesCatalogRoutes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    loadComponent: () => import('./services-catalog.component').then(m => m.ServicesCatalogComponent),
  },
];
