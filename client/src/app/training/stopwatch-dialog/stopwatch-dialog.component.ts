// import { GeneratorType } from '../generator-type.model';
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TrainingSessionAndScrambleOrSample } from '../training-session-and-scramble-or-sample.model';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { TrainingSession } from '../training-session.model';

@Component({
  selector: 'cube-trainer-stopwatch-dialog',
  templateUrl: './stopwatch-dialog.component.html',
  styleUrls: ['./stopwatch-dialog.component.css']
})
export class StopwatchDialogComponent {
  readonly scrambleOrSample: ScrambleOrSample;
  readonly trainingSession: TrainingSession;

  constructor(@Inject(MAT_DIALOG_DATA) trainingSessionAndScrambleOrSample: TrainingSessionAndScrambleOrSample) {
    this.scrambleOrSample = trainingSessionAndScrambleOrSample.scrambleOrSample;
    this.trainingSession = trainingSessionAndScrambleOrSample.trainingSession;
  }

  get hasStopAndStart(): boolean {
    // return this.trainingSession.generatorType === GeneratorType.Case;
    return false;
  }
}
