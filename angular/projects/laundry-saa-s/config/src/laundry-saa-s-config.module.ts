import {makeEnvironmentProviders} from '@angular/core';
import { LAUNDRY_SAA_S_ROUTE_PROVIDERS } from './providers/route.provider';

export function provideLaundrySaaSConfig() {
  return makeEnvironmentProviders([LAUNDRY_SAA_S_ROUTE_PROVIDERS])
}
