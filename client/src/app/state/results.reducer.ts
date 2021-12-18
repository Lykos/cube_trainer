import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure, setSelectedModeId, setPage } from '../state/results.actions';
import { ResultsState, ModeResultsState } from './results.state';
import { none, some, orElse } from '../utils/optional';
import { find } from '../utils/utils';

function initialModeResultsState(modeId: number): ModeResultsState {
  return {
    modeId,
    serverResults: [],
    initialLoadLoading: false,
    initialLoadError: none,
    createLoading: false,
    createError: none,
    destroyLoading: false,
    destroyError: none,
    markDnfLoading: false,
    markDnfError: none,
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
    return { ...modeResultsState, initialLoadLoading: true, initialLoadError: none };
  })),
  on(initialLoadSuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, serverResults: results, initialLoadLoading: false, initialLoadError: none };
  })),
  on(initialLoadFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, initialLoadLoading: false, initialLoadError: some(error) };
  })),
  on(create, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, createLoading: true, createError: none };
  })),
  on(createSuccess, (resultsState, { modeId, result }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, results: modeResultsState.serverResults.concat([result]), createLoading: false, createError: none };
  })),
  on(createFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, createLoading: false, createError: some(error) };
  })),  
  on(destroy, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, destroyLoading: true, destroyError: none };
  })),
  on(destroySuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, results: modeResultsState.serverResults.filter(m => !results.some(r => m.id !== r.id)), destroyLoading: false, destroyError: none };
  })),
  on(destroyFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, destroyLoading: false, destroyError: some(error) };
  })),  
  on(markDnf, (resultsState, { modeId }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, markDnfLoading: true, markDnfError: none };
  })),
  on(markDnfSuccess, (resultsState, { modeId, results }) => changeForMode(resultsState, modeId, modeResultsState => {
    const resultsWithDnfs = modeResultsState.serverResults.map(result => {
      return orElse(find(results, r => r.id === result.id), result);
    });
    return { ...modeResultsState, results: resultsWithDnfs, markDnfLoading: false, markDnfError: none };
  })),
  on(markDnfFailure, (resultsState, { modeId, error }) => changeForMode(resultsState, modeId, modeResultsState => {
    return { ...modeResultsState, markDnfLoading: false, markDnfError: some(error) };
  })),
  on(setSelectedModeId, (resultsState, { selectedModeId }) => {
    return { ...resultsState, selectedModeId };
  }),
  on(setPage, (resultsState, { pageIndex, pageSize }) => {
    return { ...resultsState, pageIndex, pageSize };
  }),
)
