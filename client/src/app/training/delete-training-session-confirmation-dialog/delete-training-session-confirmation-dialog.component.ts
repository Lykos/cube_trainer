import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { TrainingSession } from '../training-session.model';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'cube-trainer-delete-training-session-confirmation-dialog',
  templateUrl: './delete-training-session-confirmation-dialog.component.html',
  imports: [MatDialogModule, MatButtonModule],
})
export class DeleteTrainingSessionConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public trainingSession: TrainingSession) {}
}
