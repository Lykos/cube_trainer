import { Component } from '@angular/core';

@Component({
  selector: 'cube-trainer',
  template: `
<toolbar>Loading toolbar...</toolbar>
<div class='cube-trainer-container'>
<router-outlet></router-outlet>
</div>
`,
  styles: [`
.cube-trainer-container {
  margin: 20px;
}
`]
})
export class AppComponent {
}
