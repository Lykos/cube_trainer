export interface FieldError {
  readonly field: string;
  readonly messages: readonly string[];
}

export interface BackendActionContext {
  readonly subject: string;
  readonly action: string;
}

export interface BackendActionError {
  readonly context: BackendActionContext;
  readonly message?: string;
  readonly status?: number;
  readonly statusText?: string;
  readonly fieldErrors: readonly FieldError[];
}
