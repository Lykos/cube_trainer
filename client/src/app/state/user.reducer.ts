import { createReducer, on } from '@ngrx/store';

import { login, loginSuccess, loginFailure } from './user.actions';
import { UserState } from './user.state';
import { none, some } from '../utils/optional';

export const initialUserState: UserState = {user: none, loading: false, error: none};

export const userReducer = createReducer(
  initialUserState,
  on(login, (userState, { credentials }) => { return { user: none, loading: true, error: none }; }),
  on(loginSuccess, (userState, { user }) => { return { user: some(user), loading: false, error: none }; }),
  on(loginFailure, (userState, { error }) => { return { user: none, loading: false, error: some(error) }; }),
);
