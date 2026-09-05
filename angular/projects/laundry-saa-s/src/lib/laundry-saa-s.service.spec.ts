import { TestBed } from '@angular/core/testing';
import { LaundrySaaSService } from './services/laundry-saa-s.service';
import { RestService } from '@abp/ng.core';
import { vi } from 'vitest';

describe('LaundrySaaSService', () => {
  let service: LaundrySaaSService;
  const mockRestService = {
    request: vi.fn(),
  };

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        {
          provide: RestService,
          useValue: mockRestService,
        },
      ],
    });
    service = TestBed.inject(LaundrySaaSService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
