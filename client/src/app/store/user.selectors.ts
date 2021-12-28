import { createSelector, createFeatureSelector } from '@ngrx/store';
import { UserState } from './user.state';

export const selectUserState = createFeatureSelector<UserState>('user');

export const selectUser = createSelector(
  selectUserState,
  userState => userState.user);
