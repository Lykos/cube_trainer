import { createReducer, on } from '@ngrx/store';

import { initialLoad, initialLoadSuccess, initialLoadFailure, login, loginSuccess, loginFailure, logout, logoutSuccess, logoutFailure } from './user.actions';
import { UserState } from './user.state';
import { none, some } from '@utils/optional';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

export const initialUserState: UserState = {
  user: none,
  initialLoadState: backendActionNotStartedState,
  loginState: backendActionNotStartedState,
  logoutState: backendActionNotStartedState,
};

export const userReducer = createReducer(
  initialUserState,
  on(initialLoad, (userState) => { return { ...userState, loginState: backendActionLoadingState }; }),
  on(initialLoadSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginState: backendActionSuccessState }; }),
  on(initialLoadFailure, (userState, { error }) => { return { ...userState, loginState: backendActionFailureState(error) }; }),
  on(login, (userState, { credentials }) => { return { ...userState, loginState: backendActionLoadingState }; }),
  on(loginSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginState: backendActionSuccessState }; }),
  on(loginFailure, (userState, { error }) => { return { ...userState, loginState: backendActionFailureState(error) }; }),
  on(logout, (userState) => { return { ...userState, logoutState: backendActionLoadingState }; }),
  on(logoutSuccess, (userState) => { return { ...userState, user: none, logoutState: backendActionSuccessState }; }),
  on(logoutFailure, (userState, { error }) => { return { ...userState, logoutState: backendActionFailureState(error) }; }),
);
