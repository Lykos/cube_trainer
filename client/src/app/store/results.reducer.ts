import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure, setSelectedModeId, setPage } from '@store/results.actions';
import { ResultsState, ModeResultsState } from './results.state';
import { orElse } from '@utils/optional';
import { find } from '@utils/utils';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

function initialModeResultsState(modeId: number): ModeResultsState {
  return {
    modeId,
    serverResults: [],
    initialLoadState: backendActionNotStartedState,
    createState: backendActionNotStartedState,
    destroyState: backendActionNotStartedState,
    markDnfState: backendActionNotStartedState,
  };
};

const initialResultsState: ResultsState = {
  modeResultsStates: [],
  selectedModeId: 0,
  pageIndex: 0,
  pageSize: 20,
};

function changeForMode(resultsState: ResultsState, modeId: number, f: (modeResultState: ModeResultsState) => ModeResultsState): ResultsState {
  if (resultsState.modeResultsStates.some(s => s.modeId === modeId)) {
    const modeResultsStates = resultsState.modeResultsStates.map(s => s.modeId === modeId ? f(s) : s);
    return { ...resultsState, modeResultsStates };
  } else {
    const newModeResultsState = f(initialModeResultsState(modeId));
    return { ...resultsState, modeResultsStates: resultsState.modeResultsStates.concat([newModeResultsState]) };
  }
}

export const resultsReducer = createReducer(
  initialResultsState,
  on(initialLoad, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, initialLoadState: backendActionLoadingState };
  })),
  on(initialLoadSuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, serverResults: results, initialLoadState: backendActionSuccessState };
  })),
  on(initialLoadFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, initialLoadState: backendActionFailureState(error) };
  })),
  on(create, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, createState: backendActionLoadingState };
  })),
  on(createSuccess, (resultsState, { modeId, result }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, serverResults: [result, ...modeResultsState.serverResults], createState: backendActionSuccessState };
  })),
  on(createFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, createState: backendActionFailureState(error) };
  })),  
  on(destroy, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, destroyState: backendActionLoadingState };
  })),
  on(destroySuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, serverResults: modeResultsState.serverResults.filter(m => !results.some(r => m.id === r.id)), destroyState: backendActionSuccessState };
  })),
  on(destroyFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, destroyState: backendActionFailureState(error) };
  })),  
  on(markDnf, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, markDnfState: backendActionLoadingState };
  })),
  on(markDnfSuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    const resultsWithDnfs = modeResultsState.serverResults.map(result => {
      return orElse(find(results, r => r.id === result.id), result);
    });
    return { ...modeResultsState, serverResults: resultsWithDnfs, markDnfState: backendActionSuccessState };
  })),
  on(markDnfFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, markDnfState: backendActionFailureState(error) };
  })),
  on(setSelectedModeId, (resultsState, { selectedModeId }) => {
    return { ...resultsState, selectedModeId };
  }),
  on(setPage, (resultsState, { pageIndex, pageSize }) => {
    return { ...resultsState, pageIndex, pageSize };
  }),
)
