import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { TrainerComponent } from './trainer.component';
import { TrainerService } from './trainer.service';
import { ResultService } from './result.service';
import { InstantPipe } from './instant.pipe';
import { DurationPipe } from './duration.pipe';
import { MatTableModule } from '@angular/material/table';
import { TrainerInputComponent } from './trainer_input.component';
import { ResultTableComponent } from './result_table.component';
import { RailsModule } from '../rails/rails.module';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';

@NgModule({
  declarations: [
    TrainerComponent,
    TrainerInputComponent,
    ResultTableComponent,
    InstantPipe,
    DurationPipe,
  ],
  imports: [
    BrowserModule,
    MatCardModule,
    MatTableModule,
    MatButtonModule,
    BrowserAnimationsModule,
    RailsModule,
  ],
  exports: [
    TrainerComponent,
  ],
  providers: [
    TrainerService,
    ResultService,
  ],
})
export class TrainerModule {}
