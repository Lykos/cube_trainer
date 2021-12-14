import { createReducer, on } from '@ngrx/store';

import { initialLoad, initialLoadSuccess, initialLoadFailure, login, loginSuccess, loginFailure, logout, logoutSuccess, logoutFailure } from './user.actions';
import { UserState } from './user.state';
import { none, some } from '../utils/optional';

export const initialUserState: UserState = {
  user: none,
  initialLoadLoading: false,
  initialLoadError: none,
  loginLoading: false,
  loginError: none,
  logoutLoading: false,
  logoutError: none,
};

export const userReducer = createReducer(
  initialUserState,
  on(initialLoad, (userState) => { return { ...userState, loginLoading: true, loginError: none }; }),
  on(initialLoadSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginLoading: false, loginError: none }; }),
  on(initialLoadFailure, (userState, { error }) => { return { ...userState, loginLoading: false, loginError: some(error) }; }),
  on(login, (userState, { credentials }) => { return { ...userState, loginLoading: true, loginError: none }; }),
  on(loginSuccess, (userState, { user }) => { return { ...userState, user: some(user), loginLoading: false, loginError: none }; }),
  on(loginFailure, (userState, { error }) => { return { ...userState, loginLoading: false, loginError: some(error) }; }),
  on(logout, (userState) => { return { ...userState, logoutLoading: true, logoutError: none }; }),
  on(logoutSuccess, (userState) => { return { ...userState, user: none, logoutLoading: false, logoutError: none }; }),
  on(logoutFailure, (userState, { error }) => { return { ...userState, logoutLoading: false, logoutError: some(error) }; }),
);
