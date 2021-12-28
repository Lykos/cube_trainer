import { CdkStepperModule } from '@angular/cdk/stepper';
import { DeleteModeConfirmationDialogComponent } from './delete-mode-confirmation-dialog/delete-mode-confirmation-dialog.component';
import { DragDropModule } from '@angular/cdk/drag-drop';
import { ModesComponent } from './modes/modes.component';
import { NewColorSchemeComponent } from './new-color-scheme/new-color-scheme.component'
import { NewLetterSchemeComponent } from './new-letter-scheme/new-letter-scheme.component'
import { NewModeComponent } from './new-mode/new-mode.component';
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { OverrideAlgDialogComponent } from './override-alg-dialog/override-alg-dialog.component';
import { ResultsTableComponent } from './results-table/results-table.component';
import { SharedModule } from '@shared/shared.module';
import { StatsTableComponent } from './stats-table/stats-table.component';
import { StopwatchComponent } from './stopwatch/stopwatch.component';
import { TrainerComponent } from './trainer/trainer.component';
import { TrainerInputComponent } from './trainer-input/trainer-input.component';

@NgModule({
  declarations: [
    DeleteModeConfirmationDialogComponent,
    ModesComponent,
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    NewModeComponent,
    OverrideAlgDialogComponent,
    ResultsTableComponent,
    StatsTableComponent,
    StopwatchComponent,
    TrainerComponent,
    TrainerInputComponent,
  ],
  imports: [
    CdkStepperModule,
    DragDropModule,
    SharedModule,
  ],
  exports: [
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    NewModeComponent,
    ModesComponent,
    StatsTableComponent,
    TrainerComponent,
  ],
  entryComponents: [
    DeleteModeConfirmationDialogComponent,
  ],
  schemas: [
    CUSTOM_ELEMENTS_SCHEMA,
  ]
})
export class TrainingModule {}
