import { Component, Input } from '@angular/core';
import { BackendActionError } from '@shared/backend-action-error.model';

@Component({
  selector: 'cube-trainer-backend-action-load-error',
  templateUrl: './backend-action-load-error.component.html',
  styleUrls: ['./backend-action-load-error.component.css'],
  standalone: false,
})
export class BackendActionLoadErrorComponent {
  @Input()
  error?: BackendActionError;
}
