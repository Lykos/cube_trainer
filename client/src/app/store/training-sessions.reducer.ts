import { createReducer, on } from '@ngrx/store';
import {
  initialLoad,
  initialLoadSuccess,
  initialLoadFailure,
  loadOne,
  loadOneSuccess,
  loadOneFailure,
  create,
  createSuccess,
  createFailure,
  destroy,
  destroySuccess,
  destroyFailure,
  createAlgOverride,
  createAlgOverrideSuccess,
  createAlgOverrideFailure,
  updateAlgOverride,
  updateAlgOverrideSuccess,
  updateAlgOverrideFailure,
  setAlg,
  setAlgSuccess,
  setAlgFailure,
  setSelectedTrainingSessionId,
} from './training-sessions.actions';
import { TrainingSessionsState } from './training-sessions.state';
import { TrainingSession } from '@training/training-session.model';
import { TrainingCase } from '@training/training-case.model';
import { AlgOverride } from '@training/alg-override.model';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';
import { EntityAdapter, createEntityAdapter } from '@ngrx/entity';
 
const adapter: EntityAdapter<TrainingSession> = createEntityAdapter<TrainingSession>({
  selectId: s => s.id,
  sortComparer: (s, t) => s.name.localeCompare(t.name),
});

const initialTrainingSessionsState: TrainingSessionsState = adapter.getInitialState({
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  destroyState: backendActionNotStartedState,
  createAlgOverrideState: backendActionNotStartedState,
  updateAlgOverrideState: backendActionNotStartedState,
  setAlgState: backendActionNotStartedState,
  loadOneState: backendActionNotStartedState,
  selectedTrainingSessionId: 0,
});

function addAlgOverrideToTrainingCase(trainingCase: TrainingCase, algOverride: AlgOverride): TrainingCase {
  return { ...trainingCase, alg: algOverride.alg, algSource: { tag: 'overridden', algOverrideId: algOverride.id} };
}

function addAlgOverrideToTrainingCases(trainingCases: readonly TrainingCase[], algOverride: AlgOverride): TrainingCase[] {
  return trainingCases.map(t => t.casee.key === algOverride.casee.key ? addAlgOverrideToTrainingCase(t, algOverride) : t);
}

function addAlgOverrideToTrainingSession(trainingSessionId: number, algOverride: AlgOverride) {
  return {
    id: trainingSessionId,
    map: (trainingSession: TrainingSession) => ({ ...trainingSession, trainingCases: addAlgOverrideToTrainingCases(trainingSession.trainingCases, algOverride) }),
  };
}

export const trainingSessionsReducer = createReducer(
  initialTrainingSessionsState,
  on(initialLoad, (trainingSessionState) => {
    return { ...trainingSessionState, initialLoadState: backendActionLoadingState };
  }),
  on(initialLoadSuccess, (trainingSessionState, { trainingSessions }) => {
    return adapter.setAll(trainingSessions.map(t => t), { ...trainingSessionState, initialLoadState: backendActionSuccessState });
  }),
  on(initialLoadFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, initialLoadState: backendActionFailureState(error) };
  }),
  on(loadOne, (trainingSessionState) => {
    return { ...trainingSessionState, loadOneState: backendActionLoadingState };
  }),
  on(loadOneSuccess, (trainingSessionState, { trainingSession }) => {
    return adapter.upsertOne(trainingSession, { ...trainingSessionState, loadOneState: backendActionSuccessState });
  }),
  on(loadOneFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, loadOneState: backendActionFailureState(error) };
  }),
  on(create, (trainingSessionState, { newTrainingSession }) => {
    return { ...trainingSessionState, createState: backendActionLoadingState };
  }),
  on(createSuccess, (trainingSessionState, { trainingSession, newTrainingSession }) => {
    return adapter.addOne(trainingSession, { ...trainingSessionState, createState: backendActionSuccessState });
  }),
  on(createFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, createError: backendActionFailureState(error) };
  }),  
  on(destroy, (trainingSessionState, { trainingSession }) => {
    return { ...trainingSessionState, destroyState: backendActionLoadingState };
  }),
  on(destroySuccess, (trainingSessionState, { trainingSession }) => {
    return adapter.removeOne(trainingSession.id, { ...trainingSessionState, destroyState: backendActionSuccessState });
  }),
  on(destroyFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, destroyState: backendActionFailureState(error) };
  }),  
  on(createAlgOverride, (trainingSessionState) => {
    return { ...trainingSessionState, createAlgOverrideState: backendActionLoadingState };
  }),
  on(createAlgOverrideSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return adapter.mapOne(
      addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
      { ...trainingSessionState, createAlgOverrideState: backendActionSuccessState }
    );
  }),
  on(createAlgOverrideFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, createAlgOverrideState: backendActionFailureState(error) };
  }),  
  on(updateAlgOverride, (trainingSessionState) => {
    return { ...trainingSessionState, updateAlgOverrideState: backendActionLoadingState };
  }),
  on(updateAlgOverrideSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return adapter.mapOne(
      addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
      { ...trainingSessionState, updateAlgOverrideState: backendActionSuccessState }
    );
  }),
  on(updateAlgOverrideFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, updateAlgOverrideState: backendActionFailureState(error) };
  }),  
  on(setAlg, (trainingSessionState) => {
    return { ...trainingSessionState, setAlgState: backendActionLoadingState };
  }),
  on(setAlgSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return adapter.mapOne(
      addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
      { ...trainingSessionState, setAlgState: backendActionSuccessState }
    );
  }),
  on(setAlgFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, setAlgState: backendActionFailureState(error) };
  }),  
  on(setSelectedTrainingSessionId, (trainingSessionState, { selectedTrainingSessionId }) => {
    return { ...trainingSessionState, selectedTrainingSessionId };
  }),
)

const selectors = adapter.getSelectors();

export const selectTrainingSessionEntities = selectors.selectEntities;
export const selectAllTrainingSessions = selectors.selectAll;
