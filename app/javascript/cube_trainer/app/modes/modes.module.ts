import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { RailsModule } from '../rails/rails.module';
import { UsersModule } from '../users/users.module';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModesService } from './modes.service';
import { StatsService } from './stats.service';
import { RxReactiveFormsModule } from "@rxweb/reactive-form-validators"
import { StatsTableComponent } from './stats-table.component';
import { ModesComponent } from './modes.component';
import { NewModeComponent } from './new-mode.component';
import { NgModule } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { UtilsModule } from '../utils/utils.module';
import { MatSelectModule } from '@angular/material/select';
import { DragDropModule } from '@angular/cdk/drag-drop';
import { MatStepperModule } from '@angular/material/stepper';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { CdkStepperModule } from '@angular/cdk/stepper';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatRippleModule } from '@angular/material/core';
import { MatTooltipModule } from '@angular/material/tooltip';

@NgModule({
  declarations: [
    StatsTableComponent,
    ModesComponent,
    NewModeComponent,
  ],
  imports: [
    BrowserModule,
    RailsModule,
    MatSnackBarModule,
    UsersModule,
    UtilsModule,
    MatProgressSpinnerModule,
    MatRippleModule,
    BrowserAnimationsModule,
    MatTableModule,
    RouterModule,
    MatButtonModule,
    MatStepperModule,
    CdkStepperModule,
    MatTableModule,
    MatCardModule,
    MatInputModule,
    MatFormFieldModule,
    DragDropModule,
    MatSelectModule,
    MatCheckboxModule,
    FormsModule,
    ReactiveFormsModule,
    RxReactiveFormsModule,
    MatTooltipModule,
  ],
  providers: [
    ModesService,
    StatsService,
    UniqueModeNameValidator,
  ],
  exports: [
    StatsTableComponent,
    ModesComponent,
    NewModeComponent,
  ],
})
export class ModesModule {}
