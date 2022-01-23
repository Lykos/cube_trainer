import { createAction, props } from '@ngrx/store';
import { ColorScheme } from '@training/color-scheme.model';
import { NewColorScheme } from '@training/new-color-scheme.model';
import { BackendActionError } from '@shared/backend-action-error.model';
 
export const initialLoad = createAction(
  '[ColorScheme] initial load'
);
 
export const initialLoadSuccess = createAction(
  '[ColorScheme] initial load success',
  props<{ colorScheme: ColorScheme }>(),
);
 
export const initialLoadFailure = createAction(
  '[ColorScheme] initial load failure',
  props<{ error: BackendActionError }>()
);

export const create = createAction(
  '[ColorScheme] create',
  props<{ newColorScheme: NewColorScheme }>(),
);
 
export const createSuccess = createAction(
  '[ColorScheme] create success',
  props<{ newColorScheme: NewColorScheme, colorScheme: ColorScheme }>()
);
 
export const createFailure = createAction(
  '[ColorScheme] create failure',
  props<{ error: BackendActionError }>()
);

export const update = createAction(
  '[ColorScheme] update',
  props<{ newColorScheme: NewColorScheme }>(),
);
 
export const updateSuccess = createAction(
  '[ColorScheme] update success',
  props<{ newColorScheme: NewColorScheme, colorScheme: ColorScheme }>(),
);
 
export const updateFailure = createAction(
  '[ColorScheme] update failure',
  props<{ error: BackendActionError }>()
);
