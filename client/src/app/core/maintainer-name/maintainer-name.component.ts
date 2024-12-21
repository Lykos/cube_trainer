import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';

// Exists mainly for the purpose of finding all places where we use
// the maintainer name s.t. we can easily adapt it in case it's ever needed.
@Component({
  selector: 'cube-trainer-maintainer-name',
  templateUrl: './maintainer-name.component.html',
  standalone: false,
})
export class MaintainerNameComponent {
  get maintainerEmail() {
    return METADATA.maintainer.email;
  }

  get maintainerName() {
    return METADATA.maintainer.name;
  }
}
