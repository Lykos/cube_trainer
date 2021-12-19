import { createAction, props } from '@ngrx/store';
import { Mode } from '../modes/mode.model';
import { NewMode } from '../modes/new-mode.model';

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
  '[Modes] deleteClick',
  props<{ mode: Mode }>()
);
 
export const dontDestroy = createAction(
  '[Modes] dontDestroy',
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
