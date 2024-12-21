import { CdkStepperModule } from '@angular/cdk/stepper';
import { DeleteTrainingSessionConfirmationDialogComponent } from './delete-training-session-confirmation-dialog/delete-training-session-confirmation-dialog.component';
import { DragDropModule } from '@angular/cdk/drag-drop';
import { TrainingSessionsComponent } from './training-sessions/training-sessions.component';
import { EditColorSchemeComponent } from './edit-color-scheme/edit-color-scheme.component'
import { EditColorSchemeFormComponent } from './edit-color-scheme-form/edit-color-scheme-form.component'
import { EditLetterSchemeComponent } from './edit-letter-scheme/edit-letter-scheme.component'
import { EditLetterSchemeFormComponent } from './edit-letter-scheme-form/edit-letter-scheme-form.component'
import { NewTrainingSessionComponent } from './new-training-session/new-training-session.component';
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { OverrideAlgDialogComponent } from './override-alg-dialog/override-alg-dialog.component';
import { MatDialogModule } from '@angular/material/dialog';
import { ResultsTableComponent } from './results-table/results-table.component';
import { SharedModule } from '@shared/shared.module';
import { StatsTableComponent } from './stats-table/stats-table.component';
import { TrainerStopwatchComponent } from './trainer-stopwatch/trainer-stopwatch.component';
import { TrainerComponent } from './trainer/trainer.component';
import { TrainerInputComponent } from './trainer-input/trainer-input.component';
import { HintComponent } from './hint/hint.component';
import { StopwatchComponent } from './stopwatch/stopwatch.component';
import { StatPartValueComponent } from './stat-part-value/stat-part-value.component';
import { SelectStatsComponent } from './select-stats/select-stats.component';
import { AlgSetComponent } from './alg-set/alg-set.component';
import { TrainingSessionComponent } from './training-session/training-session.component';
import { StopwatchDialogComponent } from './stopwatch-dialog/stopwatch-dialog.component';

@NgModule({
    imports: [
        CdkStepperModule,
        DragDropModule,
        SharedModule,
        MatDialogModule,
        DeleteTrainingSessionConfirmationDialogComponent,
        TrainingSessionsComponent,
        EditColorSchemeComponent,
        EditColorSchemeFormComponent,
        EditLetterSchemeComponent,
        EditLetterSchemeFormComponent,
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
        SelectStatsComponent,
        AlgSetComponent,
        TrainingSessionComponent,
        StopwatchDialogComponent,
    ],
    exports: [
        EditColorSchemeComponent,
        EditLetterSchemeComponent,
        NewTrainingSessionComponent,
        TrainingSessionsComponent,
        StatsTableComponent,
        TrainerComponent,
    ],
    schemas: [
        CUSTOM_ELEMENTS_SCHEMA,
    ]
})
export class TrainingModule {}
