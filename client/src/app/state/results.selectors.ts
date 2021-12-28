import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ResultsState } from './results.state';
import { orElse, mapOptional } from '../utils/optional';
import { find } from '../utils/utils';

export const selectResultsState = createFeatureSelector<ResultsState>('results');

export const selectSelectedModeResultsState = createSelector(
  selectResultsState,
  resultsState => find(resultsState.modeResultsStates, m => m.modeId === resultsState.selectedModeId));

export const selectSelectedModeResults = createSelector(
  selectSelectedModeResultsState,
  modeResultsState => orElse(mapOptional(modeResultsState, m => m.serverResults), []));

export const selectSelectedModeNumResults = createSelector(
  selectSelectedModeResults,
  results => results.length);

export const selectSelectedModeResultsOnPage = createSelector(
  selectResultsState,
  resultsState => orElse(
    mapOptional(find(resultsState.modeResultsStates, m => m.modeId === resultsState.selectedModeId),
                m => m.serverResults.slice(resultsState.pageIndex * resultsState.pageSize, (resultsState.pageSize + 1) * resultsState.pageSize)),
    []));

export const selectSelectedModeNumResultsOnPage = createSelector(
  selectResultsState,
  resultsState => orElse(
    mapOptional(find(resultsState.modeResultsStates, m => m.modeId === resultsState.selectedModeId),
                m => Math.max(m.serverResults.length - resultsState.pageIndex * resultsState.pageSize, resultsState.pageSize)),
    0));

export const selectSelectedModeAnyLoading = createSelector(
  selectSelectedModeResultsState,
  modeResultsState => orElse(mapOptional(modeResultsState, m => m.initialLoadLoading || m.createLoading || m.destroyLoading || m.markDnfLoading), false));
