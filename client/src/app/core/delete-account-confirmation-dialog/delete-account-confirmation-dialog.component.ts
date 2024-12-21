import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { User } from '../user.model';

@Component({
  selector: 'cube-trainer-delete-account-confirmation-dialog',
  templateUrl: './delete-account-confirmation-dialog.component.html',
  imports: [MatDialogModule],
})
export class DeleteAccountConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public user: User) {}
}
