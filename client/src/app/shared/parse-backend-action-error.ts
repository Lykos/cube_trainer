import { HttpErrorResponse } from '@angular/common/http';
import { FieldError, BackendActionContext, BackendActionError } from './backend-action-error.model';

function parseFieldErrors(error: object): FieldError[] {
  const fieldErrors: FieldError[] = [];
  for (let [field, messages] of Object.entries(error)) {
    fieldErrors.push({ field, messages });
  }
  return fieldErrors;
}

function parseMessage(error: any): string | undefined {
  if (typeof error !== 'object') {
    return error;
  } else if (Array.isArray(error)) {
    return error.toString();
  }
  return undefined;
}

export function parseBackendActionError(context: BackendActionContext, error: HttpErrorResponse | Error): BackendActionError {
  if (error instanceof HttpErrorResponse) {
    const fieldErrors = typeof error === 'object' && !Array.isArray(error) ? parseFieldErrors(error.error) : [];
    const message = parseMessage(error);
    return {
      context,
      status: error.status,
      statusText: error.statusText,
      fieldErrors,
      message,
    };
  } else {
    return {
      context,
      message: error.message,
      fieldErrors: [],
    }  
  }
}
