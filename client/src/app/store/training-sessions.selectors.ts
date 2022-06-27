import { createSelector, createFeatureSelector } from '@ngrx/store';
import { TrainingSessionsState } from './training-sessions.state';
import { selectSelectedTrainingSessionId } from './router.selectors';
import {
  selectTrainingSessionEntities as selectTrainingSessionEntitiesFunction,
  selectTrainingSessionSummaries as selectTrainingSessionSummariesFunction,
} from './training-sessions.reducer';
import { isBackendActionLoading, isBackendActionFailure, isBackendActionNotStarted, maybeBackendActionError } from '@shared/backend-action-state.model';
import { flatMapOptional, ofNull } from '@utils/optional';

export const selectTrainingSessionsState = createFeatureSelector<TrainingSessionsState>('trainingSessions');

export const selectTrainingSessionSummaries = createSelector(
  selectTrainingSessionsState,
  state => selectTrainingSessionSummariesFunction(state.trainingSessionSummaries),
);

export const selectInitialLoadLoading = createSelector(
  selectTrainingSessionsState,
  state => isBackendActionLoading(state.initialLoadState),
);

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectTrainingSessionsState,
  state => isBackendActionLoading(state.initialLoadState) || isBackendActionLoading(state.destroyState),
);

export const selectInitialLoadError = createSelector(
  selectTrainingSessionsState,
  state => maybeBackendActionError(state.initialLoadState),
);

export const selectIsInitialLoadFailureOrNotStarted = createSelector(
  selectTrainingSessionsState,
  state => isBackendActionFailure(state.initialLoadState) || isBackendActionNotStarted(state.initialLoadState),
);

export const selectTrainingSessionEntities = createSelector(
  selectTrainingSessionsState,
  state => selectTrainingSessionEntitiesFunction(state.trainingSessions),
);

export const selectSelectedTrainingSession = createSelector(
  selectTrainingSessionEntities,
  selectSelectedTrainingSessionId,
  (entities, maybeId) => flatMapOptional(maybeId, id => ofNull(entities[id])),
);
