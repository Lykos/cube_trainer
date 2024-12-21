import { Component, Input } from '@angular/core';
import { BackendActionError } from '@shared/backend-action-error.model';
import { GithubErrorNoteComponent } from '../github-error-note/github-error-note.component';

@Component({
  selector: 'cube-trainer-backend-action-load-error',
  templateUrl: './backend-action-load-error.component.html',
  styleUrls: ['./backend-action-load-error.component.css'],
  imports: [GithubErrorNoteComponent],
})
export class BackendActionLoadErrorComponent {
  @Input()
  error?: BackendActionError;
}
