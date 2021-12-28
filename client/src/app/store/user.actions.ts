import { createAction, props } from '@ngrx/store';
import { User } from '@core/user.model';
import { BackendActionError } from '@shared/backend-action-error.model';
import { Credentials } from '@core/credentials.model';
 
export const initialLoad = createAction(
  '[User] initial load'
);
 
export const initialLoadSuccess = createAction(
  '[User] initial load success',
  props<{ user: User }>()
);
 
export const initialLoadFailure = createAction(
  '[User] initial load failure',
  props<{ error: BackendActionError }>()
);

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
  props<{ error: BackendActionError }>()
);

export const logout = createAction(
  '[User] logout'
);
 
export const logoutSuccess = createAction(
  '[User] logout success'
);
 
export const logoutFailure = createAction(
  '[User] logout failure',
  props<{ error: BackendActionError }>()
);
