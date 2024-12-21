import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { BackendActionError, FieldError } from '../backend-action-error.model';
import { GithubErrorNoteComponent } from '../github-error-note/github-error-note.component';

@Component({
  selector: 'cube-trainer-backend-action-error-dialog',
  templateUrl: './backend-action-error-dialog.component.html',
  styleUrls: ['./backend-action-error-dialog.component.css'],
  imports: [GithubErrorNoteComponent],
})
export class BackendActionErrorDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) readonly error: BackendActionError) {}

  get context() {
    return this.error.context;
  }

  noMessage(fieldError: FieldError): boolean {
    return fieldError.messages.length === 0;
  }

  uniqueMessage(fieldError: FieldError): string | false {
    return fieldError.messages.length === 1 && fieldError.messages[0];
  }

  multipleMessages(fieldError: FieldError): boolean {
    return fieldError.messages.length > 1;
  }
}
