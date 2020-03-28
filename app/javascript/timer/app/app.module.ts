import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { TimerComponent } from './app.component';

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
export class AppModule { }
