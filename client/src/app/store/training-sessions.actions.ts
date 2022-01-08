import { createAction, props } from '@ngrx/store';
import { TrainingSession } from '@training/training-session.model';
import { TrainingCase } from '@training/training-case.model';
import { BackendActionError } from '@shared/backend-action-error.model';
import { AlgOverride } from '@training/alg-override.model';
import { NewTrainingSession } from '@training/new-training-session.model';

export const initialLoad = createAction(
  '[TrainingSessions] initial load from server'
);
 
export const initialLoadNop = createAction(
  '[TrainingSessions] initial load from server nop'
);
 
export const initialLoadSuccess = createAction(
  '[TrainingSessions] initial load from server success',
  props<{ trainingSessions: readonly TrainingSession[] }>()
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
  props<{ newTrainingSession: NewTrainingSession, trainingSession: TrainingSession }>()
);
 
export const createFailure = createAction(
  '[TrainingSessions] create failure',
  props<{ error: BackendActionError }>()
);

export const deleteClick = createAction(
  '[TrainingSessions] delete click',
  props<{ trainingSession: TrainingSession }>()
);
 
export const dontDestroy = createAction(
  '[TrainingSessions] dont destroy',
  props<{ trainingSession: TrainingSession }>()
);
 
export const destroy = createAction(
  '[TrainingSessions] destroy',
  props<{ trainingSession: TrainingSession }>()
);
 
export const destroySuccess = createAction(
  '[TrainingSessions] destroy success',
  props<{ trainingSession: TrainingSession }>()
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
  props<{ trainingSession: TrainingSession, algOverride: AlgOverride }>()
);
 
export const overrideAlgSuccess = createAction(
  '[TrainingSessions] override alg success',
  props<{ trainingSession: TrainingSession, algOverride: AlgOverride }>()
);
 
export const overrideAlgFailure = createAction(
  '[TrainingSessions] override alg failure',
  props<{ error: BackendActionError }>()
);
