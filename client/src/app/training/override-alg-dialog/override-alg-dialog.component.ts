import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TrainingSessionAndCase } from '../training-session-and-case.model';
import { AlgOverride } from '../alg-override.model';

interface MutableAlgOverride extends AlgOverride {
  alg: string;
}

@Component({
  selector: 'cube-trainer-override-alg-dialog',
  templateUrl: './override-alg-dialog.component.html',
  styleUrls: ['./override-alg-dialog.component.css']
})
export class OverrideAlgDialogComponent {
  algOverride: MutableAlgOverride;

  constructor(@Inject(MAT_DIALOG_DATA) trainingSessionAndCase: TrainingSessionAndCase) {
    this.algOverride = {
      trainingCase: trainingSessionAndCase.trainingCase,
      alg: ''
    };
  }

  get trainingCase() {
    return this.algOverride.trainingCase;
  }
}
