import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { Mode } from './mode';

@Component({
  selector: 'delete-mode-confirmation-dialog',
  template: `
<h1 mat-dialog-title>Do you really want to delete mode {{mode.name}}?</h1>
<div mat-dialog-actions>
  <button mat-raised-button color="primary" [mat-dialog-close]="false" cdkFocusInitial>No</button>
  <button mat-raised-button color="primary" [mat-dialog-close]="true">Ok</button>
</div>
`
})
export class DeleteModeConfirmationDialog {
  constructor(@Inject(MAT_DIALOG_DATA) public mode: Mode) {}
}
