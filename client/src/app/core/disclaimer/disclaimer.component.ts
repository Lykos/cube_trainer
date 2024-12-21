import { Component } from '@angular/core';
import { MaintainerNameComponent } from '../maintainer-name/maintainer-name.component';

@Component({
  selector: 'cube-trainer-disclaimer',
  templateUrl: './disclaimer.component.html',
  imports: [MaintainerNameComponent],
})
export class DisclaimerComponent {}
