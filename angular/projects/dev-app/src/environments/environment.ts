import { Environment } from '@abp/ng.core';

const baseUrl = 'http://localhost:4200';

export const environment = {
  production: false,
  application: {
    baseUrl: 'http://localhost:4200/',
    name: 'LaundrySaaS',
    logoUrl: '',
  },
  oAuthConfig: {
    issuer: 'https://localhost:44384/',
    redirectUri: baseUrl,
    clientId: 'LaundrySaaS_App',
    responseType: 'code',
    scope: 'offline_access LaundrySaaS',
    requireHttps: true
  },
  apis: {
    default: {
      url: 'https://localhost:44384',
      rootNamespace: 'LaundrySaaS',
    },
    LaundrySaaS: {
      url: 'https://localhost:44328',
      rootNamespace: 'LaundrySaaS',
    },
  },
} as Environment;
