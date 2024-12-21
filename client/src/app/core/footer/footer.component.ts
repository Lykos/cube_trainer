import { Component } from '@angular/core';
import { SharedModule } from '@shared/shared.module';
import { MatToolbarModule } from '@angular/material/toolbar';

@Component({
  selector: 'cube-trainer-footer',
  templateUrl: './footer.component.html',
  imports: [SharedModule, MatToolbarModule],
})
export class FooterComponent {}
