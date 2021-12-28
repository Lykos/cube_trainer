import { createAction, props } from '@ngrx/store';
import { Mode } from '@training/mode.model';
import { Case } from '@training/case.model';
import { BackendActionError } from '@shared/backend-action-error.model';
import { AlgOverride } from '@training/alg-override.model';
import { NewMode } from '@training/new-mode.model';

export const initialLoad = createAction(
  '[Modes] initial load from server'
);
 
export const initialLoadSuccess = createAction(
  '[Modes] initial load from server success',
  props<{ modes: readonly Mode[] }>()
);
 
export const initialLoadFailure = createAction(
  '[Modes] initial load from server failure',
  props<{ error: any }>()
);

export const create = createAction(
  '[Modes] create',
  props<{ newMode: NewMode }>()
);
 
export const createSuccess = createAction(
  '[Modes] create success',
  props<{ newMode: NewMode, mode: Mode }>()
);
 
export const createFailure = createAction(
  '[Modes] create failure',
  props<{ error: any }>()
);

export const deleteClick = createAction(
  '[Modes] delete click',
  props<{ mode: Mode }>()
);
 
export const dontDestroy = createAction(
  '[Modes] dont destroy',
  props<{ mode: Mode }>()
);
 
export const destroy = createAction(
  '[Modes] destroy',
  props<{ mode: Mode }>()
);
 
export const destroySuccess = createAction(
  '[Modes] destroy success',
  props<{ mode: Mode }>()
);
 
export const destroyFailure = createAction(
  '[Modes] destroy failure',
  props<{ error: any }>()
);

export const setSelectedModeId = createAction(
  '[Modes] set selected mode id',
  props<{ selectedModeId: number }>()
);

export const overrideAlgClick = createAction(
  '[Modes] override alg click',
  props<{ mode: Mode, casee: Case }>()
);

export const dontOverrideAlg = createAction(
  '[Modes] dont override alg',
  props<{ mode: Mode }>()
);

export const overrideAlg = createAction(
  '[Modes] override alg',
  props<{ mode: Mode, algOverride: AlgOverride }>()
);
 
export const overrideAlgSuccess = createAction(
  '[Modes] override alg success',
  props<{ mode: Mode, algOverride: AlgOverride }>()
);
 
export const overrideAlgFailure = createAction(
  '[Modes] override alg failure',
  props<{ error: BackendActionError }>()
);
