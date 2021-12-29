import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure, setSelectedTrainingSessionId, setPage } from '@store/results.actions';
import { ResultsState, TrainingSessionResultsState } from './results.state';
import { orElse } from '@utils/optional';
import { find } from '@utils/utils';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

function initialTrainingSessionResultsState(trainingSessionId: number): TrainingSessionResultsState {
  return {
    trainingSessionId,
    serverResults: [],
    initialLoadState: backendActionNotStartedState,
    createState: backendActionNotStartedState,
    destroyState: backendActionNotStartedState,
    markDnfState: backendActionNotStartedState,
  };
};

const initialResultsState: ResultsState = {
  trainingSessionResultsStates: [],
  selectedTrainingSessionId: 0,
  pageIndex: 0,
  pageSize: 20,
};

function changeForTrainingSession(resultsState: ResultsState, trainingSessionId: number, f: (trainingSessionResultState: TrainingSessionResultsState) => TrainingSessionResultsState): ResultsState {
  if (resultsState.trainingSessionResultsStates.some(s => s.trainingSessionId === trainingSessionId)) {
    const trainingSessionResultsStates = resultsState.trainingSessionResultsStates.map(s => s.trainingSessionId === trainingSessionId ? f(s) : s);
    return { ...resultsState, trainingSessionResultsStates };
  } else {
    const newTrainingSessionResultsState = f(initialTrainingSessionResultsState(trainingSessionId));
    return { ...resultsState, trainingSessionResultsStates: resultsState.trainingSessionResultsStates.concat([newTrainingSessionResultsState]) };
  }
}

export const resultsReducer = createReducer(
  initialResultsState,
  on(initialLoad, (resultsState, { trainingSessionId }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, initialLoadState: backendActionLoadingState };
  })),
  on(initialLoadSuccess, (resultsState, { trainingSessionId, results }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, serverResults: results, initialLoadState: backendActionSuccessState };
  })),
  on(initialLoadFailure, (resultsState, { trainingSessionId, error }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, initialLoadState: backendActionFailureState(error) };
  })),
  on(create, (resultsState, { trainingSessionId }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, createState: backendActionLoadingState };
  })),
  on(createSuccess, (resultsState, { trainingSessionId, result }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, serverResults: [result, ...trainingSessionResultsState.serverResults], createState: backendActionSuccessState };
  })),
  on(createFailure, (resultsState, { trainingSessionId, error }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, createState: backendActionFailureState(error) };
  })),  
  on(destroy, (resultsState, { trainingSessionId }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, destroyState: backendActionLoadingState };
  })),
  on(destroySuccess, (resultsState, { trainingSessionId, results }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, serverResults: trainingSessionResultsState.serverResults.filter(m => !results.some(r => m.id === r.id)), destroyState: backendActionSuccessState };
  })),
  on(destroyFailure, (resultsState, { trainingSessionId, error }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, destroyState: backendActionFailureState(error) };
  })),  
  on(markDnf, (resultsState, { trainingSessionId }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, markDnfState: backendActionLoadingState };
  })),
  on(markDnfSuccess, (resultsState, { trainingSessionId, results }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    const resultsWithDnfs = trainingSessionResultsState.serverResults.map(result => {
      return orElse(find(results, r => r.id === result.id), result);
    });
    return { ...trainingSessionResultsState, serverResults: resultsWithDnfs, markDnfState: backendActionSuccessState };
  })),
  on(markDnfFailure, (resultsState, { trainingSessionId, error }) => changeForTrainingSession(resultsState, trainingSessionId, trainingSessionResultsState => {
    return { ...trainingSessionResultsState, markDnfState: backendActionFailureState(error) };
  })),
  on(setSelectedTrainingSessionId, (resultsState, { selectedTrainingSessionId }) => {
    return { ...resultsState, selectedTrainingSessionId };
  }),
  on(setPage, (resultsState, { pageIndex, pageSize }) => {
    return { ...resultsState, pageIndex, pageSize };
  }),
)
