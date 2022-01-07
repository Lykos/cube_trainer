import { BackendActionError } from './backend-action-error.model';
import { Optional, some, none } from '@utils/optional';

export interface BackendActionLoadingState {
  readonly tag: 'loading';
}

export interface BackendActionNotStartedState {
  readonly tag: 'not started';
}

export interface BackendActionFailureState {
  readonly tag: 'failure';
  readonly error: BackendActionError;
}

export interface BackendActionSuccessState {
  readonly tag: 'success',
}

export type BackendActionState = BackendActionNotStartedState | BackendActionSuccessState | BackendActionFailureState | BackendActionLoadingState

export const backendActionNotStartedState: BackendActionNotStartedState = { tag: 'not started' };
export const backendActionLoadingState: BackendActionLoadingState = { tag: 'loading' };

export function backendActionFailureState(error: BackendActionError): BackendActionFailureState {
  return { tag: 'failure', error };
}

export const backendActionSuccessState: BackendActionSuccessState = { tag: 'success' };

export function isBackendActionLoading(state: BackendActionState): state is BackendActionLoadingState {
  return state.tag === 'loading';
}

export function isBackendActionNotStarted(state: BackendActionState): state is BackendActionNotStartedState {
  return state.tag === 'not started';
}

export function isBackendActionSuccess(state: BackendActionState): state is BackendActionSuccessState {
  return state.tag === 'success';
}

export function isBackendActionFailure(state: BackendActionState): state is BackendActionFailureState {
  return state.tag === 'failure';
}

export function maybeBackendActionError(state: BackendActionState): Optional<BackendActionError> {
  return state.tag === 'failure' ? some(state.error) : none;
}
