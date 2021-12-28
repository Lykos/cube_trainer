import { createAction, props } from '@ngrx/store';
import { Result } from '../training/result.model';
import { Case } from '../training/case.model';
import { PartialResult } from '../training/partial-result.model';

export const initialLoad = createAction(
  '[Results] initial load from server',
  props<{ modeId: number }>()
);
 
export const initialLoadSuccess = createAction(
  '[Results] initial load from server success',
  props<{ modeId: number, results: readonly Result[] }>()
);
 
export const initialLoadFailure = createAction(
  '[Results] initial load from server failure',
  props<{ modeId: number, error: any }>()
);

export const create = createAction(
  '[Results] create',
  props<{ modeId: number, casee: Case, partialResult: PartialResult }>()
);
 
export const createSuccess = createAction(
  '[Results] create success',
  props<{ modeId: number, casee: Case, partialResult: PartialResult, result: Result }>()
);
 
export const createFailure = createAction(
  '[Results] create failure',
  props<{ modeId: number, error: any }>()
);
 
export const destroy = createAction(
  '[Results] destroy',
  props<{ modeId: number, results: Result[] }>()
);
 
export const destroySuccess = createAction(
  '[Results] destroy success',
  props<{ modeId: number, results: Result[] }>()
);
 
export const destroyFailure = createAction(
  '[Results] destroy failure',
  props<{ modeId: number, error: any }>()
);

export const markDnf = createAction(
  '[Results] mark DNF',
  props<{ modeId: number, results: Result[] }>()
);
 
export const markDnfSuccess = createAction(
  '[Results] mark DNF success',
  props<{ modeId: number, results: Result[] }>()
);
 
export const markDnfFailure = createAction(
  '[Results] mark DNF failure',
  props<{ modeId: number, error: any }>()
);

export const setSelectedModeId = createAction(
  '[Results] set selected mode id',
  props<{ selectedModeId: number }>()
);

export const setPage = createAction(
  '[Results] set page',
  props<{ pageIndex: number, pageSize: number }>()
);
