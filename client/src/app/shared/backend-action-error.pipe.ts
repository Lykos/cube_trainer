import { Pipe, PipeTransform } from '@angular/core';
import { BackendActionError, BackendActionContext } from './backend-action-error.model';
import { parseBackendActionError } from './parse-backend-action-error';

@Pipe({
  name: 'backendActionError'
})
export class BackendActionErrorPipe implements PipeTransform {
  transform(error: any, context: BackendActionContext): BackendActionError {
    return parseBackendActionError(context, error);
  }
}
