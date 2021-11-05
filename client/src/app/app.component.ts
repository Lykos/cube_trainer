import { Component } from '@angular/core';

@Component({
  selector: 'cube-trainer',
  template: `
<toolbar id="toolbar">Loading toolbar...</toolbar>
<div class="cube-trainer-container mat-elevation-z2">
<router-outlet></router-outlet>
</div>
`,
  styles: [`
.cube-trainer-container {
  margin-top: 20px;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 20px;
  padding-top: 10px;
  padding-left: 20px;
  padding-right: 20px;
  padding-bottom: 10px;
  max-width: 1396px;
}
`]
})
export class AppComponent {
}
