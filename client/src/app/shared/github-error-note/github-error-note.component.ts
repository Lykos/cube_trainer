import { Component, Input } from '@angular/core';
import { BackendActionError } from '@shared/backend-action-error.model';
import { METADATA } from '@shared/metadata.const';

@Component({
  selector: 'cube-trainer-github-error-note',
  templateUrl: './github-error-note.component.html',
  styleUrls: ['./github-error-note.component.css']
})
export class GithubErrorNoteComponent {
  @Input()
  error?: BackendActionError;

  get newBugLink() {
    if (!this.error) {
      return METADATA.newIssueLinks.bug;
    }
    const context = this.error.context
    const title = `${context.action} ${context.subject} failed`;
    return `${METADATA.newIssueLinks.bug}&title=${encodeURIComponent(title)}`;
  }
}
