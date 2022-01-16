import { CdkStepperModule } from '@angular/cdk/stepper';
import { DeleteTrainingSessionConfirmationDialogComponent } from './delete-training-session-confirmation-dialog/delete-training-session-confirmation-dialog.component';
import { DragDropModule } from '@angular/cdk/drag-drop';
import { TrainingSessionsComponent } from './training-sessions/training-sessions.component';
import { NewColorSchemeComponent } from './new-color-scheme/new-color-scheme.component'
import { NewLetterSchemeComponent } from './new-letter-scheme/new-letter-scheme.component'
import { NewTrainingSessionComponent } from './new-training-session/new-training-session.component';
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { OverrideAlgDialogComponent } from './override-alg-dialog/override-alg-dialog.component';
import { ResultsTableComponent } from './results-table/results-table.component';
import { SharedModule } from '@shared/shared.module';
import { StatsTableComponent } from './stats-table/stats-table.component';
import { TrainerStopwatchComponent } from './trainer-stopwatch/trainer-stopwatch.component';
import { TrainerComponent } from './trainer/trainer.component';
import { TrainerInputComponent } from './trainer-input/trainer-input.component';
import { HintComponent } from './hint/hint.component';
import { StopwatchComponent } from './stopwatch/stopwatch.component';
import { StatPartValueComponent } from './stat-part-value/stat-part-value.component';

@NgModule({
  declarations: [
    DeleteTrainingSessionConfirmationDialogComponent,
    TrainingSessionsComponent,
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    NewTrainingSessionComponent,
    OverrideAlgDialogComponent,
    ResultsTableComponent,
    StatsTableComponent,
    TrainerStopwatchComponent,
    TrainerComponent,
    TrainerInputComponent,
    HintComponent,
    StopwatchComponent,
    StatPartValueComponent,
  ],
  imports: [
    CdkStepperModule,
    DragDropModule,
    SharedModule,
  ],
  exports: [
    NewColorSchemeComponent,
    NewLetterSchemeComponent,
    NewTrainingSessionComponent,
    TrainingSessionsComponent,
    StatsTableComponent,
    TrainerComponent,
  ],
  entryComponents: [
    DeleteTrainingSessionConfirmationDialogComponent,
  ],
  schemas: [
    CUSTOM_ELEMENTS_SCHEMA,
  ]
})
export class TrainingModule {}
