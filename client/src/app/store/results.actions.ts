import { createAction, props } from '@ngrx/store';
import { Result } from '@training/result.model';
import { NewResult } from '@training/new-result.model';
import { BackendActionError } from '@shared/backend-action-error.model';

export const initialLoad = createAction(
  '[Results] initial load from server',
  props<{ trainingSessionId: number }>()
);
 
export const initialLoadSuccess = createAction(
  '[Results] initial load from server success',
  props<{ trainingSessionId: number, results: readonly Result[] }>()
);
 
export const initialLoadFailure = createAction(
  '[Results] initial load from server failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const create = createAction(
  '[Results] create',
  props<{ trainingSessionId: number, newResult: NewResult }>()
);
 
export const createSuccess = createAction(
  '[Results] create success',
  props<{ trainingSessionId: number, result: Result }>()
);
 
export const createFailure = createAction(
  '[Results] create failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);
 
export const destroy = createAction(
  '[Results] destroy',
  props<{ trainingSessionId: number, results: Result[] }>()
);
 
export const destroySuccess = createAction(
  '[Results] destroy success',
  props<{ trainingSessionId: number, results: Result[] }>()
);
 
export const destroyFailure = createAction(
  '[Results] destroy failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const markDnf = createAction(
  '[Results] mark DNF',
  props<{ trainingSessionId: number, results: Result[] }>()
);
 
export const markDnfSuccess = createAction(
  '[Results] mark DNF success',
  props<{ trainingSessionId: number, results: Result[] }>()
);
 
export const markDnfFailure = createAction(
  '[Results] mark DNF failure',
  props<{ trainingSessionId: number, error: BackendActionError }>()
);

export const setSelectedTrainingSessionId = createAction(
  '[Results] set selected training session id',
  props<{ selectedTrainingSessionId: number }>()
);

export const setPage = createAction(
  '[Results] set page',
  props<{ pageIndex: number, pageSize: number }>()
);
