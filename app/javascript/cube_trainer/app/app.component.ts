import { Component } from '@angular/core';

// TODO: Hack because we can't get <timer [mode]=""> to work.
declare global {
  interface Window {
    modeId: number;
  }
}

@Component({
  selector: 'cube-trainer',
  template: `<trainer [modeId]="modeId">Loading timer...</trainer>`
})
export class AppComponent {
  // TODO: The way we pass modeId is a terrible hack.
  get modeId() {
    return window.modeId;
  }
};
