import { createSelector, createFeatureSelector } from '@ngrx/store';
import { TrainingSessionsState } from './training-sessions.state';
import { selectSelectedTrainingSessionId } from './router.selectors';
import {
  selectTrainingSessionEntities as selectTrainingSessionEntitiesFunction,
  selectAllTrainingSessions as selectAllTrainingSessionsFunction,
} from './training-sessions.reducer';
import { isBackendActionLoading, isBackendActionFailure, isBackendActionNotStarted, maybeBackendActionError } from '@shared/backend-action-state.model';
import { flatMapOptional, ofNull } from '@utils/optional';

export const selectTrainingSessionsState = createFeatureSelector<TrainingSessionsState>('trainingSessions');

export const selectTrainingSessions = createSelector(
  selectTrainingSessionsState,
  selectAllTrainingSessionsFunction,
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
  e => selectTrainingSessionEntitiesFunction(e),
);

export const selectSelectedTrainingSession = createSelector(
  selectTrainingSessionEntities,
  selectSelectedTrainingSessionId,
  (entities, maybeId) => flatMapOptional(maybeId, id => ofNull(entities[id])),
);
