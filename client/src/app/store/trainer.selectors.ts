import { createSelector, MemoizedSelector, createFeatureSelector } from '@ngrx/store';
import { calculateStats } from '@training/calculate-stats';
import { Instant, now, fromUnixMillis } from '@utils/instant';
import { TrainingSessionAndMaybeSamplingState } from '@training/training-session-and-maybe-sampling-state.model';
import { seconds } from '@utils/duration';
import { GeneratorType } from '@training/generator-type.model';
import { TrainerState, notStartedStopwatchState, isRunning, ResultsState, IntermediateWeightState, initialIntermediateWeightState, StartAfterLoading } from './trainer.state';
import { CaseTrainingSession } from '@training/training-session.model';
import { TrainingCase } from '@training/training-case.model';
import { Case } from '@training/case.model';
import { SamplingState, WeightState } from '@utils/sampling';
import { ScrambleOrSample, isSample } from '@training/scramble-or-sample.model';
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
import { computeCubeAverage } from '@utils/cube-average';

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

interface CurrentCaseAndHintActive {
  readonly currentCase: Optional<ScrambleOrSample>;
  readonly hintActive: boolean;
};

export const selectCurrentCaseAndHintActiveById = createSelector(
  selectTrainerAll,
  trainerAll => {
    const map = new Map<number, CurrentCaseAndHintActive>();
    for (let resultsState of trainerAll) {
      const currentCase = resultsState.currentCase;
      const hintActive = resultsState.hintActive;
      map.set(resultsState.trainingSessionId, { currentCase, hintActive });
    }
    return map;
  },
);

function toWeightState(state: IntermediateWeightState, instant: Instant): WeightState {
  const badnessAverage = computeCubeAverage(state.recentBadnessesS.map(seconds));
  return {
    itemsSinceLastOccurrence: state.itemsSinceLastOccurrence,
    durationSinceLastOccurrence: fromUnixMillis(state.lastOccurrenceUnixMillis).durationUntil(instant),
    occurrenceDays: state.occurrenceDays.length,
    totalOccurrences: state.totalOccurrences,
    occurrenceDaysSinceLastHintOrDnf: mapOptional(state.lastHintOrDnfInfo, l => l.occurrenceDaysSince.length),
    badnessAverage,
  };
}

export function getIntermediateWeightState(resultsState: ResultsState, casee: Case): IntermediateWeightState {
  for (let weightState of resultsState.intermediateWeightStates) {
    if (weightState.casee.key === casee.key) {
      return weightState.state;
    }
  }
  return initialIntermediateWeightState;
}

function toSamplingState(trainingSession: CaseTrainingSession, resultsState: ResultsState, instant: Instant): SamplingState<TrainingCase> {
  const weightStates = trainingSession.trainingCases.map(
    trainingCase => {
      const intermediateWeightState = getIntermediateWeightState(resultsState, trainingCase.casee);
      return { item: trainingCase, state: toWeightState(intermediateWeightState, instant) };
    }
  );
  const nextItem = flatMapOptional(resultsState.nextCase, nextCase => isSample(nextCase) ? some(nextCase.sample.item) : none);
  return { weightStates, nextItem };
}

export const selectTrainingSessionAndSamplingStateById: MemoizedSelector<any, Optional<Map<number, TrainingSessionAndMaybeSamplingState>>> = createSelector(
  selectTrainingSessionEntities,
  selectTrainerAll,
  (trainingSessionEntities, trainerAll) => {
    if (!trainingSessionEntities) {
      return none;
    }
    const map = new Map<number, TrainingSessionAndMaybeSamplingState>();
    for (let resultsState of trainerAll) {
      const trainingSessionId = resultsState.trainingSessionId
      const trainingSession = trainingSessionEntities[trainingSessionId];
      if (!trainingSession) {
        return none;
      }
      switch (trainingSession.generatorType) {
	case GeneratorType.Case:
	  map.set(trainingSessionId, { generatorType: GeneratorType.Case, trainingSession, samplingState: toSamplingState(trainingSession, resultsState, now()) });
	  break;
	case GeneratorType.Scramble:
	  map.set(trainingSessionId, { generatorType: GeneratorType.Scramble, trainingSession });
	  break;
      }
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

export const selectCurrentCase = createSelector(
  selectResultsState,
  maybeRs => flatMapOptional(maybeRs, rs => rs.currentCase),
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
  maybeRs => orElse(mapOptional(maybeRs, rs => rs.startAfterLoading), StartAfterLoading.NONE),
);

export const selectStopwatchState = createSelector(
  selectResultsState,
  maybeRs => orElse(mapOptional(maybeRs, rs => rs.stopwatchState), notStartedStopwatchState),
);

export const selectStopwatchRunning = createSelector(
  selectStopwatchState,
  isRunning,
);
