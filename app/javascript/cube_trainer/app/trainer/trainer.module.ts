import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { TrainerComponent } from './trainer.component';
import { TrainerService } from './trainer.service';
import { RailsService } from './rails.service';
import { TrainerInputComponent } from './trainer_input.component';
import { MatSliderModule } from '@angular/material/slider';
import { MatCardModule } from '@angular/material/card';

@NgModule({
  declarations: [
    TrainerComponent,
    TrainerInputComponent,
  ],
  imports: [
    BrowserModule,
    MatSliderModule,
    MatCardModule,
    BrowserAnimationsModule,
  ],
  exports: [
    TrainerComponent,
  ],
  providers: [
    TrainerService,
    RailsService,
  ],
})
export class TrainerModule { }
