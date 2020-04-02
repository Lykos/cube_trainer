import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { TrainerComponent } from './trainer.component';
import { HackTrainerComponent } from './hack_trainer.component';
import { TrainerService } from './trainer.service';
import { TrainerInputComponent } from './trainer_input.component';
import { RailsModule } from '../rails/rails.module';
import { MatCardModule } from '@angular/material/card';

@NgModule({
  declarations: [
    TrainerComponent,
    HackTrainerComponent,
    TrainerInputComponent,
  ],
  imports: [
    BrowserModule,
    MatCardModule,
    BrowserAnimationsModule,
    RailsModule,
  ],
  exports: [
    TrainerComponent,
    HackTrainerComponent,
  ],
  providers: [
    TrainerService,
  ],
})
export class TrainerModule {}
