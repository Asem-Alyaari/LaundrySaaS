import { ComponentFixture, TestBed } from '@angular/core/testing';
import { LaundrySaaSComponent } from './components/laundry-saa-s.component';
import { LaundrySaaSService } from '@laundry-saa-s';
import { of } from 'rxjs';
import { vi } from 'vitest';

describe('LaundrySaaSComponent', () => {
  let component: LaundrySaaSComponent;
  let fixture: ComponentFixture<LaundrySaaSComponent>;
  const mockLaundrySaaSService = {
    sample: vi.fn().mockReturnValue(of([])),
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LaundrySaaSComponent],
      providers: [
        {
          provide: LaundrySaaSService,
          useValue: mockLaundrySaaSService,
        },
      ],
    }).compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(LaundrySaaSComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
