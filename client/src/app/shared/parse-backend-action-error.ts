import { HttpErrorResponse } from '@angular/common/http';
import { FieldError, BackendActionContext, BackendActionError } from './backend-action-error.model';

export function parseFieldErrors(error: object): FieldError[] {
  const fieldErrors: FieldError[] = [];
  for (let [field, messages] of Object.entries(error)) {
    fieldErrors.push({ field, messages });
  }
  return fieldErrors;
}

export function parseBackendActionError(context: BackendActionContext, error: HttpErrorResponse | Error): BackendActionError {
  if (error instanceof HttpErrorResponse) {
    return {
      context,
      status: error.status,
      statusText: error.statusText,
      fieldErrors: parseFieldErrors(error.error),
    };
  } else {
    return {
      context,
      message: error.message,
      fieldErrors: [],
    }  
  }
}
