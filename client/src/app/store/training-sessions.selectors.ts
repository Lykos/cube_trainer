import { createSelector, createFeatureSelector } from '@ngrx/store';
import { TrainingSessionsState } from './training-sessions.state';
import { find } from '@utils/utils';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';

export const selectTrainingSessionsState = createFeatureSelector<TrainingSessionsState>('trainingSessions');

export const selectTrainingSessions = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => trainingSessionsState.serverTrainingSessions);

export const selectInitialLoadLoading = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => isBackendActionLoading(trainingSessionsState.initialLoadState));

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => isBackendActionLoading(trainingSessionsState.initialLoadState) || isBackendActionLoading(trainingSessionsState.destroyState));

export const selectInitialLoadError = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => maybeBackendActionError(trainingSessionsState.initialLoadState));

export const selectSelectedTrainingSession = createSelector(
  selectTrainingSessionsState,
  trainingSessionsState => find(trainingSessionsState.serverTrainingSessions, m => m.id === trainingSessionsState.selectedTrainingSessionId));

