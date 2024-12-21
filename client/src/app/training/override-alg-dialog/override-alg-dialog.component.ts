import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TrainingSessionAndCase } from '../training-session-and-case.model';
import { NewAlgOverride } from '../new-alg-override.model';
import { MatDialogModule } from '@angular/material/dialog';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';

interface MutableAlgOverride extends NewAlgOverride {
  alg: string;
}

@Component({
  selector: 'cube-trainer-override-alg-dialog',
  templateUrl: './override-alg-dialog.component.html',
  styleUrls: ['./override-alg-dialog.component.css'],
  imports: [MatDialogModule, MatFormFieldModule, MatInputModule, FormsModule, MatButtonModule],
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
