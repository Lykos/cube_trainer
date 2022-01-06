import { createSelector, createFeatureSelector } from '@ngrx/store';
import { TrainingSessionsState } from './training-sessions.state';
import { selectRouteParam } from './router.selectors';
import {
  selectTrainingSessionEntities as selectTrainingSessionEntitiesFunction,
  selectAllTrainingSessions as selectAllTrainingSessionsFunction,
} from './training-sessions.reducer';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';
import { ofNull } from '@utils/optional';

export const selectTrainingSessionsState = createFeatureSelector<TrainingSessionsState>('trainingSessions');

export const selectTrainingSessions = createSelector(
  selectTrainingSessionsState,
  selectAllTrainingSessionsFunction,
);

export const selectInitialLoadLoading = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => isBackendActionLoading(trainingSessionsState.initialLoadState));

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => isBackendActionLoading(trainingSessionsState.initialLoadState) || isBackendActionLoading(trainingSessionsState.destroyState));

export const selectInitialLoadError = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => maybeBackendActionError(trainingSessionsState.initialLoadState));

const selectSelectedTrainingSessionId = selectRouteParam('trainingSessionId');

const selectTrainingSessionEntities = createSelector(
  selectTrainingSessionsState,
  selectTrainingSessionEntitiesFunction,
);

export const selectSelectedTrainingSession = createSelector(
  selectTrainingSessionEntities,
  selectSelectedTrainingSessionId,
  (entities, id) => ofNull(id ? entities[id] : undefined),
);

