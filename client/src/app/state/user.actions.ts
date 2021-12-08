import { createAction, props } from '@ngrx/store';
import { User } from '../users/user.model';
import { Credentials } from '../users/credentials.model';
 
export const login = createAction(
  '[User] login',
  props<{ credentials: Credentials }>()
);
 
export const loginSuccess = createAction(
  '[User] login success',
  props<{ user: User }>()
);
 
export const loginFailure = createAction(
  '[User] login failure',
  props<{ error: any }>()
);
