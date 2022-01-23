import { createAction, props } from '@ngrx/store';
import { LetterScheme } from '@training/letter-scheme.model';
import { NewLetterScheme } from '@training/new-letter-scheme.model';
import { BackendActionError } from '@shared/backend-action-error.model';
 
export const initialLoad = createAction(
  '[LetterScheme] initial load'
);
 
export const initialLoadSuccess = createAction(
  '[LetterScheme] initial load success',
  props<{ letterScheme: LetterScheme }>(),
);
 
export const initialLoadFailure = createAction(
  '[LetterScheme] initial load failure',
  props<{ error: BackendActionError }>()
);

export const create = createAction(
  '[LetterScheme] create',
  props<{ newLetterScheme: NewLetterScheme }>(),
);
 
export const createSuccess = createAction(
  '[LetterScheme] create success',
  props<{ newLetterScheme: NewLetterScheme, letterScheme: LetterScheme }>()
);
 
export const createFailure = createAction(
  '[LetterScheme] create failure',
  props<{ error: BackendActionError }>()
);

export const update = createAction(
  '[LetterScheme] update',
  props<{ newLetterScheme: NewLetterScheme }>(),
);
 
export const updateSuccess = createAction(
  '[LetterScheme] update success',
  props<{ newLetterScheme: NewLetterScheme, letterScheme: LetterScheme }>(),
);
 
export const updateFailure = createAction(
  '[LetterScheme] update failure',
  props<{ error: BackendActionError }>()
);
