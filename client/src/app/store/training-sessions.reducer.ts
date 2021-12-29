import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, overrideAlg, overrideAlgSuccess, overrideAlgFailure, setSelectedTrainingSessionId } from './training-sessions.actions';
import { TrainingSessionsState } from './training-sessions.state';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

const initialTrainingSessionsState: TrainingSessionsState = {
  serverTrainingSessions: [],
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  destroyState: backendActionNotStartedState,
  overrideAlgState: backendActionNotStartedState,
  selectedTrainingSessionId: 0,
};

export const trainingSessionsReducer = createReducer(
  initialTrainingSessionsState,
  on(initialLoad, (trainingSessionState) => {
    return { ...trainingSessionState, initialLoadState: backendActionLoadingState };
  }),
  on(initialLoadSuccess, (trainingSessionState, { trainingSessions }) => {
    return { ...trainingSessionState, serverTrainingSessions: trainingSessions, initialLoadState: backendActionSuccessState };
  }),
  on(initialLoadFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, initialLoadState: backendActionFailureState(error) };
  }),
  on(create, (trainingSessionState, { newTrainingSession }) => {
    return { ...trainingSessionState, createState: backendActionLoadingState };
  }),
  on(createSuccess, (trainingSessionState, { trainingSession, newTrainingSession }) => {
    return { ...trainingSessionState, serverTrainingSessions: trainingSessionState.serverTrainingSessions.concat([trainingSession]), createState: backendActionSuccessState };
  }),
  on(createFailure, (trainingSessionState, { error }) => {
    return { ...trainingSessionState, createError: backendActionFailureState(error) };
  }),  
  on(destroy, (trainingSessionState, { trainingSession }) => {
    return { ...trainingSessionState, destroyState: backendActionLoadingState };
  }),
  on(destroySuccess, (trainingSessionState, { trainingSession }) => {
    return { ...trainingSessionState, serverTrainingSessions: trainingSessionState.serverTrainingSessions.filter(m => m.id !== trainingSession.id), destroyState: backendActionSuccessState };
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
  on(setSelectedTrainingSessionId, (trainingSessionState, { selectedTrainingSessionId }) => {
    return { ...trainingSessionState, selectedTrainingSessionId };
  }),
)
