import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { TrainerComponent } from './trainer/trainer.component';
import { StopwatchComponent } from './stopwatch/stopwatch.component';
import { TrainerService } from './trainer.service';
import { UtilsModule } from '../utils/utils.module';
import { SharedModule } from '../shared/shared.module';
import { ModesModule } from '../modes/modes.module';
import { ResultsService } from './results.service';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { TrainerInputComponent } from './trainer-input/trainer-input.component';
import { ResultsTableComponent } from './results-table/results-table.component';
import { RailsModule } from '../rails/rails.module';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';
import { MatRippleModule } from '@angular/material/core';

@NgModule({
  declarations: [
    TrainerComponent,
    TrainerInputComponent,
    ResultsTableComponent,
    StopwatchComponent,
  ],
  imports: [
    BrowserModule,
    MatCardModule,
    MatRippleModule,
    ModesModule,
    MatTableModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    MatButtonModule,
    MatCheckboxModule,
    BrowserAnimationsModule,
    MatPaginatorModule,
    RailsModule,
    UtilsModule,
    SharedModule,
  ],
  exports: [
    TrainerComponent,
  ],
  providers: [
    TrainerService,
    ResultsService,
  ],
  schemas: [
    CUSTOM_ELEMENTS_SCHEMA,
  ]
})
export class TrainerModule {}
