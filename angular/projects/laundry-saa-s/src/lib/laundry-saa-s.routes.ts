import { RouterOutletComponent } from '@abp/ng.core';
import { Routes } from '@angular/router';
import { LaundrySaaSComponent } from './components/laundry-saa-s.component';

export const laundrySaaSRoutes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    component: RouterOutletComponent,
    children: [
      {
        path: '',
        component: LaundrySaaSComponent,
      },
    ],
  },
];
