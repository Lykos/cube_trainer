import { Component } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'cube-trainer-footer',
  templateUrl: './footer.component.html',
  imports: [MatToolbarModule, MatButtonModule, RouterModule],
})
export class FooterComponent {}
