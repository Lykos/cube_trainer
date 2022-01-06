import { createSelector, createFeatureSelector } from '@ngrx/store';
import { TrainerState } from './trainer.state';
import {
  selectTrainerEntities as selectTrainerEntitiesFunction,
  selectAllResults as selectAllResultsFunction,
  selectResultsTotal as selectResultsTotalFunction,
} from './trainer.reducer';
import { selectRouteParam } from './router.selectors';
import { orElse, mapOptional, flatMapOptional, ofNull } from '@utils/optional';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';

export const selectTrainerState = createFeatureSelector<TrainerState>('trainer');

const selectTrainerEntities = createSelector(
  selectTrainerState,
  selectTrainerEntitiesFunction,
);

const selectSelectedTrainingSessionId = selectRouteParam('trainingSessionId');

export const selectResultsState = createSelector(
  selectTrainerEntities,
  selectSelectedTrainingSessionId,
  (entities, id) => ofNull(id ? entities[id] : undefined),
);

export const selectPageIndex = createSelector(
  selectTrainerState,
  s => s.pageIndex,
);

export const selectPageSize = createSelector(
  selectTrainerState,
  s => s.pageSize,
);

export const selectResults = createSelector(
  selectResultsState,
  maybeRs => mapOptional(maybeRs, selectAllResultsFunction));

export const selectResultsTotal = createSelector(
  selectResultsState,
  maybeRs => mapOptional(maybeRs, selectResultsTotalFunction));

export const selectInitialLoadError = createSelector(
  selectResultsState,
  maybeRs => flatMapOptional(maybeRs, rs => maybeBackendActionError(rs.initialLoadState)));

export const selectResultsOnPage = createSelector(
  selectResults,
  selectPageSize,
  selectPageIndex,
  (maybeResults, pageSize, pageIndex) =>
    mapOptional(
      maybeResults,
      results => results.slice(pageIndex * pageSize, (pageIndex + 1) * pageSize)
    ),
);

export const selectResultsTotalOnPage = createSelector(
  selectResultsTotal,
  selectPageSize,
  selectPageIndex,
  (maybeResultsTotal, pageSize, pageIndex) =>
    mapOptional(
      maybeResultsTotal,
      resultsTotal => Math.max(resultsTotal - pageIndex * pageSize, pageSize)
    ),
);

export const selectInitialLoadLoading = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => isBackendActionLoading(rs.initialLoadState)), false),
);
