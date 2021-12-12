import { createReducer, on } from '@ngrx/store';

import { login, loginSuccess, loginFailure, initialLoad, initialLoadSuccess, initialLoadFailure } from './user.actions';
import { UserState } from './user.state';
import { none, some } from '../utils/optional';

export const initialUserState: UserState = {user: none, loginLoading: false, loginError: none, initialLoadLoading: false, initialLoadError: none};

export const userReducer = createReducer(
  initialUserState,
  on(login, (userState, { credentials }) => { return { ...userState, loginLoading: true, loginError: none }; }),
  on(loginSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginLoading: false, loginError: none }; }),
  on(loginFailure, (userState, { error }) => { return { ...userState, loginLoading: false, loginError: some(error) }; }),
  on(initialLoad, (userState) => { return { ...userState, loginLoading: true, loginError: none }; }),
  on(initialLoadSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginLoading: false, loginError: none }; }),
  on(initialLoadFailure, (userState, { error }) => { return { ...userState, loginLoading: false, loginError: some(error) }; }),
);
