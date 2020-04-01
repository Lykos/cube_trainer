import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { CubeTrainerComponent } from './cube_trainer.component';
import { TimerComponent } from './timer.component';
import { TimerInputComponent } from './timer_input.component';
import { MatSliderModule } from '@angular/material/slider';
import { MatCardModule } from '@angular/material/card';

@NgModule({
  declarations: [
    CubeTrainerComponent,
    TimerComponent,
    TimerInputComponent,
  ],
  imports: [
    BrowserModule,
    MatSliderModule,
    MatCardModule,
    BrowserAnimationsModule,
  ],
  providers: [],
  bootstrap: [
    CubeTrainerComponent,
  ]
})
export class CubeTrainerModule { }
