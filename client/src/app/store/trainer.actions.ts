import { createAction, props } from '@ngrx/store';
import { Result } from '@training/result.model';
import { NewResult } from '@training/new-result.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import { BackendActionError } from '@shared/backend-action-error.model';

export const initialLoadSelected = createAction(
  '[Trainer] initial load everything the trainer needs for the selected training session from server'
);
 
export const initialLoad = createAction(
  '[Trainer] initial load everything the trainer needs from server',
  props<{ trainingSessionId: number }>()
);

export const initialLoadResults = createAction(
  '[Trainer] initial load results from server',
  props<{ trainingSessionId: number }>()
);
 
export const initialLoadResultsNop = createAction(
  '[Trainer] initial load results from server nop',
  props<{ trainingSessionId: number }>()
);
 
export const initialLoadResultsSuccess = createAction(
  '[Trainer] initial load results from server success',
  props<{ trainingSessionId: number, results: readonly Result[] }>()
);
 
export const initialLoadResultsFailure = createAction(
  '[Trainer] initial load results from server failure',
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
  '[Trainer] load next case for the selected training session',
  props<{ trainingSessionId: number }>()
);
 
export const loadNextCase = createAction(
  '[Trainer] load next case',
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

export const stopAndStartStopwatch = createAction(
  '[Trainer] stop stopwatch and start again once the next case is loaded',
  props<{ trainingSessionId: number, stopUnixMillis: number }>()
);

export const stopAndPauseStopwatch = createAction(
  '[Trainer] stop stopwatch and do not start again once the next case is loaded',
  props<{ trainingSessionId: number, stopUnixMillis: number }>()
);

export const stopStopwatch = createAction(
  '[Trainer] stop stopwatch',
  props<{ trainingSessionId: number, stopUnixMillis: number }>()
);

export const stopStopwatchSuccess = createAction(
  '[Trainer] stop stopwatch success',
  props<{ trainingSessionId: number, durationMillis: number }>()
);

export const stopStopwatchFailure = createAction(
  '[Trainer] stop stopwatch failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const showHint = createAction(
  '[Trainer] show hint',
  props<{ trainingSessionId: number }>()
);
