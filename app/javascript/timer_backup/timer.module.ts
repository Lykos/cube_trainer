import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { TimerComponent } from './timer.component';

@NgModule({
  declarations: [
    TimerComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [TimerComponent]
})
export class TimerModule {}
