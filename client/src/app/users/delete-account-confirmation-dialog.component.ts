import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { User } from './user.model';

@Component({
  selector: 'cube-trainer-delete-account-confirmation-dialog',
  templateUrl: './delete-account-confirmation-dialog.component.html'
})
export class DeleteAccountConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public user: User) {}
}
