import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ResultsState } from './results.state';
import { orElse, mapOptional, flatMapOptional } from '@utils/optional';
import { find } from '@utils/utils';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';

export const selectResultsState = createFeatureSelector<ResultsState>('results');

export const selectSelectedTrainingSessionResultsState = createSelector(
  selectResultsState,
  resultsState => find(resultsState.trainingSessionResultsStates, m => m.trainingSessionId === resultsState.selectedTrainingSessionId));

export const selectSelectedTrainingSessionResults = createSelector(
  selectSelectedTrainingSessionResultsState,
  trainingSessionResultsState => orElse(mapOptional(trainingSessionResultsState, m => m.serverResults), []));

export const selectSelectedTrainingSessionNumResults = createSelector(
  selectSelectedTrainingSessionResults,
  results => results.length);

export const selectInitialLoadError = createSelector(
  selectSelectedTrainingSessionResultsState,
  results => flatMapOptional(results, rs => maybeBackendActionError(rs.initialLoadState)));

export const selectSelectedTrainingSessionResultsOnPage = createSelector(
  selectResultsState,
  resultsState => orElse(
    mapOptional(find(resultsState.trainingSessionResultsStates, m => m.trainingSessionId === resultsState.selectedTrainingSessionId),
                m => m.serverResults.slice(resultsState.pageIndex * resultsState.pageSize, (resultsState.pageSize + 1) * resultsState.pageSize)),
    []));

export const selectSelectedTrainingSessionNumResultsOnPage = createSelector(
  selectResultsState,
  resultsState => orElse(
    mapOptional(find(resultsState.trainingSessionResultsStates, m => m.trainingSessionId === resultsState.selectedTrainingSessionId),
                m => Math.max(m.serverResults.length - resultsState.pageIndex * resultsState.pageSize, resultsState.pageSize)),
    0));

export const selectSelectedTrainingSessionAnyLoading = createSelector(
  selectSelectedTrainingSessionResultsState,
  trainingSessionResultsState => orElse(mapOptional(trainingSessionResultsState, m => isBackendActionLoading(m.initialLoadState) || isBackendActionLoading(m.createState) || isBackendActionLoading(m.destroyState) || isBackendActionLoading(m.markDnfState)), false));
