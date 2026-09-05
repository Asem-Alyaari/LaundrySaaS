import { ApplicationConfig } from '@angular/core';
import { provideAnimations } from "@angular/platform-browser/animations";
import { provideRouter } from "@angular/router";
import { registerLocaleData } from '@angular/common';
import localeAr from '@angular/common/locales/ar';
import { appRoutes } from './app.routes';

registerLocaleData(localeAr);
import { APP_ROUTE_PROVIDER } from './route.provider';
import { provideAbpCore, withOptions } from '@abp/ng.core';
import { environment } from '../environments/environment';
import { registerLocale } from '@abp/ng.core/locale';
import { provideAbpOAuth } from '@abp/ng.oauth';
import { provideAbpThemeShared } from '@abp/ng.theme.shared';
import { provideSettingManagementConfig } from '@abp/ng.setting-management/config';
import { provideAccountConfig } from '@abp/ng.account/config';
import { provideIdentityConfig } from '@abp/ng.identity/config';
import { provideTenantManagementConfig } from '@abp/ng.tenant-management/config';
import { provideFeatureManagementConfig } from '@abp/ng.feature-management';
import {provideThemeBasicConfig} from "@abp/ng.theme.basic";
import {provideLaundrySaaSConfig} from "@laundry-saa-s/config";

import { provideNzI18n, ar_EG } from 'ng-zorro-antd/i18n';
import { provideNzIcons } from 'ng-zorro-antd/icon';
import {
  DashboardOutline,
  ShopOutline,
  TeamOutline,
  CarOutline,
  ShoppingCartOutline,
  UserOutline,
  SettingOutline,
  LogoutOutline,
  DownOutline,
  MenuFoldOutline,
  MenuUnfoldOutline,
  BellOutline,
  HomeOutline,
} from '@ant-design/icons-angular/icons';

const icons = [
  DashboardOutline,
  ShopOutline,
  TeamOutline,
  CarOutline,
  ShoppingCartOutline,
  UserOutline,
  SettingOutline,
  LogoutOutline,
  DownOutline,
  MenuFoldOutline,
  MenuUnfoldOutline,
  BellOutline,
  HomeOutline,
];

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(appRoutes),
    APP_ROUTE_PROVIDER,
    provideAbpCore(
      withOptions({
        environment,
        registerLocaleFn: registerLocale(),
        sendNullsAsQueryParam: false,
        skipGetAppConfiguration: false,
      })
    ),
    provideAbpOAuth(),
    provideAbpThemeShared(),
    provideSettingManagementConfig(),
    provideAccountConfig(),
    provideIdentityConfig(),
    provideTenantManagementConfig(),
    provideFeatureManagementConfig(),
    provideAnimations(),
    provideThemeBasicConfig(),
    provideLaundrySaaSConfig(),
    provideNzI18n(ar_EG),
    provideNzIcons(icons),
  ],
};

