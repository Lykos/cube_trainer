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

export const initialLoad = createAction(
  '[User] initialLoad'
);
 
export const initialLoadSuccess = createAction(
  '[User] initial load success',
  props<{ user: User }>()
);
 
export const initialLoadFailure = createAction(
  '[User] initial load failure',
  props<{ error: any }>()
);
