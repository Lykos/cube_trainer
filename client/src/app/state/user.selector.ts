import { createSelector, createFeatureSelector } from '@ngrx/store';
import { User } from './user.model';

export const selectUserState = createFeatureSelector<UserState>('user');

export const selectUser = createSelector(
  selectUserState,
  userState => userState.user);
