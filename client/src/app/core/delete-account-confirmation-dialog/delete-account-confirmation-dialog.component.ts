import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { User } from '../user.model';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'cube-trainer-delete-account-confirmation-dialog',
  templateUrl: './delete-account-confirmation-dialog.component.html',
  imports: [MatDialogModule, MatButtonModule],
})
export class DeleteAccountConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public user: User) {}
}
