import { HttpErrorResponse } from '@angular/common/http';
import { FieldError, BackendActionContext, BackendActionError } from './backend-action-error.model';

interface AuthErrorData {
  readonly status: string;
  readonly data: object;
  readonly errors: object;
}

interface FieldlessAuthErrorData {
  readonly success?: boolean;
  readonly errors: readonly string[];
}

function isAuthErrorData(error: object): error is AuthErrorData {
  const authErrorData = error as AuthErrorData;
  return !!authErrorData.status && !!authErrorData.data && !!authErrorData.errors && Object.keys(authErrorData).length === 3;
}

function isFieldlessAuthErrorData(error: object): error is FieldlessAuthErrorData {
  const fieldlessAuthErrorData = error as FieldlessAuthErrorData;
  return (fieldlessAuthErrorData.success !== undefined && !!fieldlessAuthErrorData.errors && Object.keys(fieldlessAuthErrorData).length === 2) ||
    (!!fieldlessAuthErrorData.errors && Object.keys(fieldlessAuthErrorData).length === 1);
}

function parseFieldErrors(error: object): FieldError[] {
  // Requests to /api/auth return a different format and we have to account for it.
  if (isFieldlessAuthErrorData(error)) {
    return [];
  }
  if (isAuthErrorData(error)) {
    error = error.errors;
  }
  const fieldErrors: FieldError[] = [];
  for (let [field, messages] of Object.entries(error)) {
    if (field !== 'full_messages') {
      fieldErrors.push({ field, messages });
    }
  }
  return fieldErrors;
}

function parseMessage(error: any): string | undefined {
  if (error && error.error && isFieldlessAuthErrorData(error.error)) {
    error = error.error.errors;
  }
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
