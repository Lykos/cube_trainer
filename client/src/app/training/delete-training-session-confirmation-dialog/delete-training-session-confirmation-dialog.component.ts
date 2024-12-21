import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { TrainingSession } from '../training-session.model';

@Component({
  selector: 'cube-trainer-delete-training-session-confirmation-dialog',
  templateUrl: './delete-training-session-confirmation-dialog.component.html',
  standalone: false,
})
export class DeleteTrainingSessionConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public trainingSession: TrainingSession) {}
}
