import { createAction, props } from '@ngrx/store';
import { TrainingSession } from '@training/training-session.model';
import { TrainingSessionSummary } from '@training/training-session-summary.model';
import { TrainingCase } from '@training/training-case.model';
import { BackendActionError } from '@shared/backend-action-error.model';
import { AlgOverride } from '@training/alg-override.model';
import { NewAlgOverride } from '@training/new-alg-override.model';
import { NewTrainingSession } from '@training/new-training-session.model';

export const initialLoad = createAction(
  '[TrainingSessions] initial load from server'
);
 
export const initialLoadNop = createAction(
  '[TrainingSessions] initial load from server nop'
);
 
export const initialLoadSuccess = createAction(
  '[TrainingSessions] initial load from server success',
  props<{ trainingSessionSummaries: readonly TrainingSessionSummary[] }>()
);
 
export const initialLoadFailure = createAction(
  '[TrainingSessions] initial load from server failure',
  props<{ error: BackendActionError }>()
);

export const loadOne = createAction(
  '[TrainingSessions] load one from server',
  props<{ trainingSessionId: number }>()
);
  
export const loadOneSuccess = createAction(
  '[TrainingSessions] load one from server success',
  props<{ trainingSession: TrainingSession }>()
);
 
export const loadOneFailure = createAction(
  '[TrainingSessions] load one from server failure',
  props<{ error: BackendActionError }>()
);

export const create = createAction(
  '[TrainingSessions] create',
  props<{ newTrainingSession: NewTrainingSession }>()
);
 
export const createSuccess = createAction(
  '[TrainingSessions] create success',
  props<{ newTrainingSession: NewTrainingSession, trainingSessionSummary: TrainingSessionSummary }>()
);
 
export const createFailure = createAction(
  '[TrainingSessions] create failure',
  props<{ error: BackendActionError }>()
);

export const deleteClick = createAction(
  '[TrainingSessions] delete click',
  props<{ trainingSession: TrainingSessionSummary }>()
);
 
export const dontDestroy = createAction(
  '[TrainingSessions] dont destroy',
  props<{ trainingSession: TrainingSessionSummary }>()
);
 
export const destroy = createAction(
  '[TrainingSessions] destroy',
  props<{ trainingSession: TrainingSessionSummary }>()
);
 
export const destroySuccess = createAction(
  '[TrainingSessions] destroy success',
  props<{ trainingSession: TrainingSessionSummary }>()
);
 
export const destroyFailure = createAction(
  '[TrainingSessions] destroy failure',
  props<{ error: BackendActionError }>()
);

export const setSelectedTrainingSessionId = createAction(
  '[TrainingSessions] set selected trainingSession id',
  props<{ selectedTrainingSessionId: number }>()
);

export const overrideAlgClick = createAction(
  '[TrainingSessions] override alg click',
  props<{ trainingSession: TrainingSession, trainingCase: TrainingCase }>()
);

export const dontOverrideAlg = createAction(
  '[TrainingSessions] dont override alg',
  props<{ trainingSession: TrainingSession }>()
);

export const overrideAlg = createAction(
  '[TrainingSessions] override alg',
  props<{ trainingSession: TrainingSession, newAlgOverride: NewAlgOverride }>()
);
 
export const createAlgOverride = createAction(
  '[TrainingSessions] create alg override',
  props<{ trainingSession: TrainingSession, newAlgOverride: NewAlgOverride }>()
);
 
export const createAlgOverrideSuccess = createAction(
  '[TrainingSessions] create alg override success',
  props<{ trainingSession: TrainingSession, algOverride: AlgOverride }>()
);
 
export const createAlgOverrideFailure = createAction(
  '[TrainingSessions] create alg override failure',
  props<{ error: BackendActionError }>()
);

export const updateAlgOverride = createAction(
  '[TrainingSessions] update alg override',
  props<{ trainingSession: TrainingSession, algOverrideId: number, newAlgOverride: NewAlgOverride }>()
);
 
export const updateAlgOverrideSuccess = createAction(
  '[TrainingSessions] update alg override success',
  props<{ trainingSession: TrainingSession, algOverride: AlgOverride }>()
);
 
export const updateAlgOverrideFailure = createAction(
  '[TrainingSessions] update alg override failure',
  props<{ error: BackendActionError }>()
);

export const setAlgClick = createAction(
  '[TrainingSessions] set alg click',
  props<{ trainingSession: TrainingSession, trainingCase: TrainingCase }>()
);

export const dontSetAlg = createAction(
  '[TrainingSessions] dont set alg',
  props<{ trainingSession: TrainingSession }>()
);

export const setAlg = createAction(
  '[TrainingSessions] set alg',
  props<{ trainingSession: TrainingSession, newAlgOverride: NewAlgOverride }>()
);
 
export const setAlgSuccess = createAction(
  '[TrainingSessions] set alg success',
  props<{ trainingSession: TrainingSession, algOverride: AlgOverride }>()
);
 
export const setAlgFailure = createAction(
  '[TrainingSessions] set alg failure',
  props<{ error: BackendActionError }>()
);
