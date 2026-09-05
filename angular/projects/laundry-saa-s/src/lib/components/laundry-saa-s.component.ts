import { Component, inject, OnInit } from '@angular/core';
import { LaundrySaaSService } from '../services/laundry-saa-s.service';

@Component({
  selector: 'lib-laundry-saa-s',
  template: ` <p>laundry-saa-s works!</p> `,
  styles: [],
})
export class LaundrySaaSComponent implements OnInit {
  private service = inject(LaundrySaaSService);

  ngOnInit(): void {
    this.service.sample().subscribe(console.log);
  }
}
