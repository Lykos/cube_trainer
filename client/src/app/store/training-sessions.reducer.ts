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
import { createSuccess as createResultSuccess, destroySuccess as destroyResultSuccess } from './trainer.actions';
import { TrainingSessionsState } from './training-sessions.state';
import { TrainingSession } from '@training/training-session.model';
import { TrainingSessionSummary } from '@training/training-session-summary.model';
import { TrainingCase } from '@training/training-case.model';
import { AlgOverride } from '@training/alg-override.model';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';
import { EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { addAlgOverrideToTrainingCase } from './reducer-utils';
 
const summariesAdapter: EntityAdapter<TrainingSessionSummary> = createEntityAdapter<TrainingSessionSummary>({
  selectId: s => s.id,
  sortComparer: (s, t) => s.name.localeCompare(t.name),
});

const adapter: EntityAdapter<TrainingSession> = createEntityAdapter<TrainingSession>({
  selectId: s => s.id,
  sortComparer: (s, t) => s.name.localeCompare(t.name),
});

const initialTrainingSessionsState: TrainingSessionsState = {
  trainingSessions: adapter.getInitialState({}),
  trainingSessionSummaries: summariesAdapter.getInitialState({}),
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  destroyState: backendActionNotStartedState,
  createAlgOverrideState: backendActionNotStartedState,
  updateAlgOverrideState: backendActionNotStartedState,
  setAlgState: backendActionNotStartedState,
  loadOneState: backendActionNotStartedState,
  selectedTrainingSessionId: 0,
};

function toEmptySummary(trainingSession: TrainingSession): TrainingSessionSummary {
  return {
    name: trainingSession.name,
    id: trainingSession.id,
    numResults: 0,
  };
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
  on(initialLoadSuccess, (trainingSessionState, { trainingSessionSummaries }) => {
    return {
      ...trainingSessionState,
      initialLoadState: backendActionSuccessState,
      trainingSessionSummaries: summariesAdapter.setAll(trainingSessionSummaries.map(t => t), trainingSessionState.trainingSessionSummaries)
    };
  }),
  on(initialLoadFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, initialLoadState: backendActionFailureState(error) };
  }),
  on(loadOne, (trainingSessionState) => {
    return { ...trainingSessionState, loadOneState: backendActionLoadingState };
  }),
  on(loadOneSuccess, (trainingSessionState, { trainingSession }) => {
    return {
      ...trainingSessionState,
      loadOneState: backendActionSuccessState,
      trainingSessions: adapter.upsertOne(trainingSession, trainingSessionState.trainingSessions),
    }
  }),
  on(loadOneFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, loadOneState: backendActionFailureState(error) };
  }),
  on(create, (trainingSessionState, { newTrainingSession }) => {
    return { ...trainingSessionState, createState: backendActionLoadingState };
  }),
  on(createSuccess, (trainingSessionState, { trainingSession, newTrainingSession }) => {
    return {
      ...trainingSessionState,
      createState: backendActionSuccessState,
      trainingSessions: adapter.addOne(trainingSession, trainingSessionState.trainingSessions),
      trainingSessionSummaries: summariesAdapter.addOne(toEmptySummary(trainingSession), trainingSessionState.trainingSessionSummaries),
    }
  }),
  on(createFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, createError: backendActionFailureState(error) };
  }),  
  on(destroy, (trainingSessionState, { trainingSession }) => {
    return { ...trainingSessionState, destroyState: backendActionLoadingState };
  }),
  on(destroySuccess, (trainingSessionState, { trainingSession }) => {
    return {
      ...trainingSessionState,
      destroyState: backendActionSuccessState,
      trainingSessions: adapter.removeOne(trainingSession.id, trainingSessionState.trainingSessions),
      trainingSessionSummaries: summariesAdapter.removeOne(trainingSession.id, trainingSessionState.trainingSessionSummaries),
    }
  }),
  on(destroyFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, destroyState: backendActionFailureState(error) };
  }),  
  on(createAlgOverride, (trainingSessionState) => {
    return { ...trainingSessionState, createAlgOverrideState: backendActionLoadingState };
  }),
  on(createAlgOverrideSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return {
      ...trainingSessionState,
      createAlgOverrideState: backendActionSuccessState,
      trainingSessions: adapter.mapOne(
	addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
	trainingSessionState.trainingSessions,
      )
    };
  }),
  on(createAlgOverrideFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, createAlgOverrideState: backendActionFailureState(error) };
  }),  
  on(updateAlgOverride, (trainingSessionState) => {
    return { ...trainingSessionState, updateAlgOverrideState: backendActionLoadingState };
  }),
  on(updateAlgOverrideSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return {
      ...trainingSessionState,
      updateAlgOverrideState: backendActionSuccessState,
      trainingSessions: adapter.mapOne(
	addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
	trainingSessionState.trainingSessions,
      )
    };
  }),
  on(updateAlgOverrideFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, updateAlgOverrideState: backendActionFailureState(error) };
  }),  
  on(setAlg, (trainingSessionState) => {
    return { ...trainingSessionState, setAlgState: backendActionLoadingState };
  }),
  on(setAlgSuccess, (trainingSessionState, { trainingSession, algOverride }) => {
    return {
      ...trainingSessionState,
      destroyState: backendActionSuccessState,
      trainingSessions: adapter.mapOne(
	addAlgOverrideToTrainingSession(trainingSession.id, algOverride),
	trainingSessionState.trainingSessions,
      )
    };
  }),
  on(setAlgFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, setAlgState: backendActionFailureState(error) };
  }),  
  on(setSelectedTrainingSessionId, (trainingSessionState, { selectedTrainingSessionId }) => {
    return { ...trainingSessionState, selectedTrainingSessionId };
  }),
  on(createResultSuccess, (trainingSessionState, { trainingSessionId }) => {
    return {
      ...trainingSessionState,
      trainingSessionSummaries: summariesAdapter.mapOne(
	{
	  id: trainingSessionId,
	  map: trainingSession => ({ ...trainingSession, numResults: trainingSession.numResults + 1 }),
	},
	trainingSessionState.trainingSessionSummaries,
      )
    };
  }),
  on(destroyResultSuccess, (trainingSessionState, { trainingSessionId }) => {
    return {
      ...trainingSessionState,
      trainingSessionSummaries: summariesAdapter.mapOne(
	{
	  id: trainingSessionId,
	  map: trainingSession => ({ ...trainingSession, numResults: trainingSession.numResults - 1 }),
	},
	trainingSessionState.trainingSessionSummaries,
      )
    };
  }),
)

const selectors = adapter.getSelectors();
const summarySelectors = summariesAdapter.getSelectors();

export const selectTrainingSessionEntities = selectors.selectEntities;
export const selectTrainingSessionSummaries = summarySelectors.selectAll;
