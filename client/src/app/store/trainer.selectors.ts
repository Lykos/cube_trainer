import { createSelector, MemoizedSelector, createFeatureSelector } from '@ngrx/store';
import { calculateStats } from '@training/calculate-stats';
import { TrainerState, notStartedStopwatchState, isRunning } from './trainer.state';
import { TrainingSession } from '@training/training-session.model';
import { Result } from '@training/result.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import {
  selectTrainerEntities as selectTrainerEntitiesFunction,
  selectTrainerAll as selectTrainerAllFunction,
  selectAllResults as selectAllResultsFunction,
  selectResultsTotal as selectResultsTotalFunction,
} from './trainer.reducer';
import { selectSelectedTrainingSessionId } from './router.selectors';
import { selectTrainingSessionEntities, selectSelectedTrainingSession } from './training-sessions.selectors';
import { Optional, orElse, mapOptional, flatMapOptional, ofNull, some, none, hasValue } from '@utils/optional';
import { isBackendActionLoading, isBackendActionFailure, isBackendActionNotStarted, maybeBackendActionError } from '@shared/backend-action-state.model';

export const selectTrainerState = createFeatureSelector<TrainerState>('trainer');

const selectTrainerEntities = createSelector(
  selectTrainerState,
  selectTrainerEntitiesFunction,
);

const selectTrainerAll = createSelector(
  selectTrainerState,
  selectTrainerAllFunction,
);

export const selectIsInitialLoadNecessaryById = createSelector(
  selectTrainerAll,
  trainerAll => {
    const map = new Map<number, boolean>();
    for (let resultsState of trainerAll) {
      const answer =
        isBackendActionFailure(resultsState.initialLoadResultsState) ||
        isBackendActionNotStarted(resultsState.initialLoadResultsState);
      map.set(resultsState.trainingSessionId, answer);
    }
    return map;
  },
);

interface NextCaseAndHintActive {
  readonly nextCase: Optional<ScrambleOrSample>;
  readonly hintActive: boolean;
};

export const selectNextCaseAndHintActiveById = createSelector(
  selectTrainerAll,
  trainerAll => {
    const map = new Map<number, NextCaseAndHintActive>();
    for (let resultsState of trainerAll) {
      const nextCase = resultsState.nextCase;
      const hintActive = resultsState.hintActive;
      map.set(resultsState.trainingSessionId, { nextCase, hintActive });
    }
    return map;
  },
);

interface TrainingSessionAndResults {
  readonly trainingSession: TrainingSession;
  readonly results: readonly Result[];
};

export const selectTrainingSessionAndResultsById: MemoizedSelector<any, Optional<Map<number, TrainingSessionAndResults>>> = createSelector(
  selectTrainingSessionEntities,
  selectTrainerAll,
  (trainingSessionEntities, trainerAll) => {
    if (!trainingSessionEntities) {
      return none;
    }
    const map = new Map<number, TrainingSessionAndResults>();
    for (let resultsState of trainerAll) {
      const trainingSessionId = resultsState.trainingSessionId
      const trainingSession = trainingSessionEntities[trainingSessionId];
      if (!trainingSession) {
        return none;
      }
      const results = selectAllResultsFunction(resultsState);
      map.set(trainingSessionId, { trainingSession, results });
    }
    return some(map);
  },
);

export const selectResultsState = createSelector(
  selectTrainerEntities,
  selectSelectedTrainingSessionId,
  (entities, maybeId) => flatMapOptional(maybeId, id => ofNull(entities[id])),
);

export const selectPageState = createSelector(
  selectTrainerState,
  s => s.pageState,
);

export const selectPageIndex = createSelector(
  selectPageState,
  s => s.pageIndex,
);

export const selectPageSize = createSelector(
  selectPageState,
  s => s.pageSize,
);

export const selectResults = createSelector(
  selectResultsState,
  maybeRs => mapOptional(maybeRs, selectAllResultsFunction)
);


export const selectStats = createSelector(
  selectSelectedTrainingSession,
  selectResults,
  (maybeTrainingSession, maybeResults) => flatMapOptional(
    maybeTrainingSession,
    trainingSession =>
      mapOptional(
	maybeResults,
	results => calculateStats(trainingSession, results)
      )
  )
);

export const selectResultsTotal = createSelector(
  selectResultsState,
  maybeRs => mapOptional(maybeRs, selectResultsTotalFunction));

export const selectInitialLoadError = createSelector(
  selectResultsState,
  maybeRs => flatMapOptional(maybeRs, rs => maybeBackendActionError(rs.initialLoadResultsState)));

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
      resultsTotal => Math.min(resultsTotal - pageIndex * pageSize, pageSize)
    ),
);

export const selectInitialLoadLoading = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => isBackendActionLoading(rs.initialLoadResultsState)), false),
);

export const selectNextCase = createSelector(
  selectResultsState,
  maybeRs => flatMapOptional(maybeRs, rs => rs.nextCase),
);

export const selectNextCaseReady = createSelector(
  selectNextCase,
  hasValue,
);

export const selectHintActive = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => rs.hintActive), false),
);

export const selectStartAfterLoading = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => rs.startAfterLoading), false),
);

export const selectStopwatchState = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => rs.stopwatchState), notStartedStopwatchState),
);

export const selectStopwatchRunning = createSelector(
  selectStopwatchState,
  isRunning,
);
