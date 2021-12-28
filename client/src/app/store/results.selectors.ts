import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ResultsState } from './results.state';
import { orElse, mapOptional, flatMapOptional } from '@utils/optional';
import { find } from '@utils/utils';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';

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

export const selectInitialLoadError = createSelector(
  selectSelectedModeResultsState,
  results => flatMapOptional(results, rs => maybeBackendActionError(rs.initialLoadState)));

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
  modeResultsState => orElse(mapOptional(modeResultsState, m => isBackendActionLoading(m.initialLoadState) || isBackendActionLoading(m.createState) || isBackendActionLoading(m.destroyState) || isBackendActionLoading(m.markDnfState)), false));
