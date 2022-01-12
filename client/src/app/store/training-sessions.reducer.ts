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
  overrideAlg,
  overrideAlgSuccess,
  overrideAlgFailure,
  setAlg,
  setAlgSuccess,
  setAlgFailure,
  setSelectedTrainingSessionId,
} from './training-sessions.actions';
import { TrainingSessionsState } from './training-sessions.state';
import { TrainingSession } from '@training/training-session.model';
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
  overrideAlgState: backendActionNotStartedState,
  setAlgState: backendActionNotStartedState,
  loadOneState: backendActionNotStartedState,
  selectedTrainingSessionId: 0,
});

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
  on(overrideAlg, (trainingSessionState) => {
    return { ...trainingSessionState, overrideAlgState: backendActionLoadingState };
  }),
  on(overrideAlgSuccess, (trainingSessionState) => {
    return { ...trainingSessionState, overrideAlgState: backendActionSuccessState };
  }),
  on(overrideAlgFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, overrideAlgState: backendActionFailureState(error) };
  }),  
  on(setAlg, (trainingSessionState) => {
    return { ...trainingSessionState, setAlgState: backendActionLoadingState };
  }),
  on(setAlgSuccess, (trainingSessionState) => {
    return { ...trainingSessionState, setAlgState: backendActionSuccessState };
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
