import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { TrainerComponent } from './trainer.component';
import { TrainerService } from './trainer.service';
import { UtilsModule } from '../utils/utils.module';
import { ResultService } from './result.service';
import { MatTableModule } from '@angular/material/table';
import { TrainerInputComponent } from './trainer_input.component';
import { ResultTableComponent } from './result_table.component';
import { RailsModule } from '../rails/rails.module';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';

@NgModule({
  declarations: [
    TrainerComponent,
    TrainerInputComponent,
    ResultTableComponent,
  ],
  imports: [
    BrowserModule,
    MatCardModule,
    MatTableModule,
    MatProgressSpinnerModule,
    MatButtonModule,
    BrowserAnimationsModule,
    RailsModule,
    UtilsModule,
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
