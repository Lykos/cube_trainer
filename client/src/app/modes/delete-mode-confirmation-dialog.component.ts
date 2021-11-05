import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Mode } from './mode';

@Component({
  selector: 'cube-trainer-delete-mode-confirmation-dialog',
  templateUrl: './delete-mode-confirmation-dialog.component.html'
})
export class DeleteModeConfirmationDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public mode: Mode) {}
}
