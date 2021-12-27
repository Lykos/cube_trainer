import { HttpErrorResponse } from '@angular/common/http';
import { FieldError, BackendActionContext, BackendActionError } from './backend-action-error.model';

export function parseFieldErrors(error: object): FieldError[] {
  const fieldErrors: FieldError[] = [];
  for (let [field, messages] of Object.entries(error)) {
    fieldErrors.push({ field, messages });
  }
  return fieldErrors;
}

export function parseBackendActionError(context: BackendActionContext, errorResponse: HttpErrorResponse): BackendActionError {
  return {
    context,
    status: errorResponse.status,
    statusText: errorResponse.statusText,
    fieldErrors: parseFieldErrors(errorResponse.error),
  }
}
