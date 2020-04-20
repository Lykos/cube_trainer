import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { TrainerComponent } from './trainer.component';
import { TrainerService } from './trainer.service';
import { UtilsModule } from '../utils/utils.module';
import { ModesModule } from '../modes/modes.module';
import { ResultsService } from './results.service';
import { MatTableModule } from '@angular/material/table';
import { TrainerInputComponent } from './trainer-input.component';
import { ResultsTableComponent } from './results-table.component';
import { RailsModule } from '../rails/rails.module';
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
  ],
  imports: [
    BrowserModule,
    MatCardModule,
    MatRippleModule,
    ModesModule,
    MatTableModule,
    MatProgressSpinnerModule,
    MatButtonModule,
    MatCheckboxModule,
    BrowserAnimationsModule,
    RailsModule,
    UtilsModule,
  ],
  exports: [
    TrainerComponent,
  ],
  providers: [
    TrainerService,
    ResultsService,
  ],
})
export class TrainerModule {}
