import { createAction, props } from '@ngrx/store';
import { Result } from '@training/result.model';
import { NewResult } from '@training/new-result.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import { BackendActionError } from '@shared/backend-action-error.model';

export const initialLoadSelected = createAction(
  '[Trainer] initial load results of selected training session from server'
);
 
export const initialLoad = createAction(
  '[Trainer] initial load from server',
  props<{ trainingSessionId: number }>()
);
 
export const initialLoadNop = createAction(
  '[Trainer] initial load from server nop',
  props<{ trainingSessionId: number }>()
);
 
export const initialLoadSuccess = createAction(
  '[Trainer] initial load from server success',
  props<{ trainingSessionId: number, results: readonly Result[] }>()
);
 
export const initialLoadFailure = createAction(
  '[Trainer] initial load from server failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const create = createAction(
  '[Trainer] create',
  props<{ trainingSessionId: number, newResult: NewResult }>()
);
 
export const createSuccess = createAction(
  '[Trainer] create success',
  props<{ trainingSessionId: number, result: Result }>()
);
 
export const createFailure = createAction(
  '[Trainer] create failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);
 
export const destroy = createAction(
  '[Trainer] destroy',
  props<{ trainingSessionId: number, resultIds: readonly number[] }>()
);
 
export const destroySuccess = createAction(
  '[Trainer] destroy success',
  props<{ trainingSessionId: number, resultIds: readonly number[] }>()
);
 
export const destroyFailure = createAction(
  '[Trainer] destroy failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const markDnf = createAction(
  '[Trainer] mark DNF',
  props<{ trainingSessionId: number, resultIds: readonly number[] }>()
);
 
export const markDnfSuccess = createAction(
  '[Trainer] mark DNF success',
  props<{ trainingSessionId: number, resultIds: readonly number[] }>()
);
 
export const markDnfFailure = createAction(
  '[Trainer] mark DNF failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const setPage = createAction(
  '[Trainer] set page',
  props<{ pageIndex: number, pageSize: number }>()
);

export const loadSelectedNextCase = createAction(
  '[Trainer] load next case of selected training session',
  props<{ trainingSessionId: number }>()
);
 
export const loadNextCase = createAction(
  '[Trainer] load next case',
  props<{ trainingSessionId: number }>()
);
 
export const loadNextCaseNop = createAction(
  '[Trainer] load next case nop',
  props<{ trainingSessionId: number }>()
);
 
export const loadNextCaseSuccess = createAction(
  '[Trainer] load next case success',
  props<{ trainingSessionId: number, nextCase: ScrambleOrSample }>()
);
 
export const loadNextCaseFailure = createAction(
  '[Trainer] load next case failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const startStopwatch = createAction(
  '[Trainer] start stopwatch',
  props<{ trainingSessionId: number, startUnixMillis: number }>()
);

export const stopStopwatch = createAction(
  '[Trainer] stop stopwatch',
  props<{ trainingSessionId: number, durationMillis: number }>()
);

export const showHint = createAction(
  '[Trainer] show hint',
  props<{ trainingSessionId: number }>()
);
