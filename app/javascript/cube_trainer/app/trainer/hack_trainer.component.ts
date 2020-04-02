import { Component } from '@angular/core';

@Component({
  selector: 'cube-trainer',
  template: `
<toolbar>Loading toolbar...</toolbar>
<hack-trainer>Loading trainer...</hack-trainer>
`
})
export class AppComponent {
  // TODO: The way we pass modeId is a terrible hack.
  get modeId() {
    return window.modeId;
  }
};
