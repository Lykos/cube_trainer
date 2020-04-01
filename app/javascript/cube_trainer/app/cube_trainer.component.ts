import { Component } from '@angular/core';

// TODO: Hack because we can't get <timer [mode]=""> to work.
declare global {
  interface Window {
    modeId: number;
  }
}

@Component({
  selector: 'cube-trainer',
  template: `<timer [modeId]="modeId">Loading timer...</timer>`
})
export class CubeTrainerComponent {
  // TODO: The way we pass modeId is a terrible hack.
  get modeId() {
    return window.modeId;
  }
};
