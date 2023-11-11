import { createReducer, on } from '@ngrx/store';
import {
  initialLoadResults,
  initialLoadResultsSuccess,
  initialLoadResultsFailure,
  create,
  createSuccess,
  createFailure,
  destroy,
  destroySuccess,
  destroyFailure,
  markDnf,
  markDnfSuccess,
  markDnfFailure,
  loadNextCase,
  loadNextCaseSuccess,
  loadNextCaseFailure,
  setPage,
  startStopwatch,
  stopAndStartStopwatch,
  stopAndPauseStopwatch,
  startStopwatchDialog,
  stopAndStartStopwatchDialog,
  stopAndPauseStopwatchDialog,
  stopStopwatchSuccess,
  abandonStopwatchSuccess,
  showHint,
} from '@store/trainer.actions';
import { Duration, seconds, minutes } from '@utils/duration';
import { unixEpoch } from '@utils/instant';
import { AlgOverride } from '@training/alg-override.model';
import { ScrambleOrSample, mapTrainingCase } from '@training/scramble-or-sample.model';
import { mapOptional } from '@utils/optional';
import { 
  createAlgOverrideSuccess,
  updateAlgOverrideSuccess,
  setAlgSuccess,
} from './training-sessions.actions';
import { addAlgOverrideToTrainingCase } from './reducer-utils';
import { Result } from '@training/result.model';
import { TrainerState, ResultsState, StopwatchState, notStartedStopwatchState, runningStopwatchState, stoppedStopwatchState, IntermediateWeightState, CaseAndIntermediateWeightState, LastHintOrDnfInfo, initialIntermediateWeightState, StartAfterLoading } from './trainer.state';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';
import { EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { fromDateString } from '@utils/instant';
import { Optional, none, some } from '@utils/optional';

const resultsAdapter: EntityAdapter<Result> = createEntityAdapter<Result>({
  selectId: s => s.id,
  sortComparer: (s, t) => fromDateString(t.createdAt).minusInstant(fromDateString(s.createdAt)).toMillis(),
});

const trainerAdapter: EntityAdapter<ResultsState> = createEntityAdapter<ResultsState>({
  selectId: s => s.trainingSessionId,
});

const initialPageState = {
  pageIndex: 0,
  pageSize: 10,
}

const BADNESS_MEMORY = 5;
const DNF_PENALTY = minutes(1);
const HINT_PENALTY = minutes(1);

const initialStopwatchState: StopwatchState = notStartedStopwatchState;

const initialTrainerState: TrainerState = trainerAdapter.getInitialState({
  pageState: initialPageState,
});

function addAlgOverrideToScrambleOrSample(scrambleOrSample: ScrambleOrSample, algOverride: AlgOverride): ScrambleOrSample {
  return mapTrainingCase(scrambleOrSample, t => addAlgOverrideToTrainingCase(t, algOverride));
}

function addAlgOverrideToResultsState(resultsState: ResultsState, algOverride: AlgOverride): ResultsState {
  return { ...resultsState, nextCase: mapOptional(resultsState.nextCase, t => addAlgOverrideToScrambleOrSample(t, algOverride)) };
}

function pushWithMemory<X>(xs: readonly X[], x: X, memory: number): X[] {
  if (xs.length < memory) {
    return [...xs, x];
  }
  const withoutForgotten = xs.slice(1);
  withoutForgotten.push(x);
  return withoutForgotten;
}

function badness(result: Result): Duration {
  if (!result.success) {
    return DNF_PENALTY;
  } else if (result.numHints > 0) {
    return HINT_PENALTY;
  }
  return seconds(result.timeS);
}

function updateLastHintOrDnfInfo(maybeLastHintOrDnfInfo: Optional<LastHintOrDnfInfo>, result: Result): Optional<LastHintOrDnfInfo> {
  const timestamp = fromDateString(result.createdAt);
  const daysAfterEpoch = unixEpoch.durationUntil(timestamp).toDays();
  if (result.numHints > 0 || !result.success) {
    return some({ daysAfterEpoch, occurrenceDaysSince: []});
  } else {
    return mapOptional(
      maybeLastHintOrDnfInfo,
      lastHintOrDnfInfo => {
	const dayIsAfterHintOrDnf = daysAfterEpoch > lastHintOrDnfInfo.daysAfterEpoch;
	const newDay = lastHintOrDnfInfo.occurrenceDaysSince.length === 0 || lastHintOrDnfInfo.occurrenceDaysSince[lastHintOrDnfInfo.occurrenceDaysSince.length - 1] != daysAfterEpoch;
	return dayIsAfterHintOrDnf && newDay ? { ...lastHintOrDnfInfo, occurenceDays: [...lastHintOrDnfInfo.occurrenceDaysSince, daysAfterEpoch] } : lastHintOrDnfInfo
      }
    );
  }
  
}

function addMatchingResultToEnd(weightState: IntermediateWeightState, result: Result, numResultsAfter: number) {
  const timestamp = fromDateString(result.createdAt);
  const daysAfterEpoch = unixEpoch.durationUntil(timestamp).toDays();
  const newDay = weightState.occurrenceDays.length === 0 || weightState.occurrenceDays[weightState.occurrenceDays.length - 1] != daysAfterEpoch;
  const occurrenceDays = newDay ? [...weightState.occurrenceDays, daysAfterEpoch] : weightState.occurrenceDays;
  const recentBadnessesS = pushWithMemory(weightState.recentBadnessesS, badness(result).toSeconds(), BADNESS_MEMORY);
  return {
    itemsSinceLastOccurrence: numResultsAfter,
    lastOccurrenceUnixMillis: timestamp.toUnixMillis(),
    occurrenceDays,
    lastHintOrDnfInfo: updateLastHintOrDnfInfo(weightState.lastHintOrDnfInfo, result),
    totalOccurrences: weightState.totalOccurrences + 1,
    recentBadnessesS,
  };
}

function recompute(resultsState: ResultsState): ResultsState {
  const weightStates = new Map<string, CaseAndIntermediateWeightState>();
  // Newer results come first. The only place where this matters is for `itemsSinceLastOccurrence`.
  const results = resultsState.ids.map(id => resultsState.entities[id]!);
  for (let i = results.length - 1; i >= 0; --i) {
    const result = results[i];
    const caseKey = result.casee.key;
    const weightState = weightStates.get(caseKey)?.state || initialIntermediateWeightState;
    weightStates.set(caseKey, { casee: result.casee, state: addMatchingResultToEnd(weightState, result, i) });
  }
  const intermediateWeightStates = [...weightStates.values()];
  return { ...resultsState, intermediateWeightStates };
}

export const trainerReducer = createReducer(
  initialTrainerState,
  on(initialLoadResults, (trainerState, { trainingSessionId }) => {
    const initialResultsState = resultsAdapter.getInitialState({
      trainingSessionId,
      initialLoadResultsState: backendActionLoadingState,
      createState: backendActionNotStartedState,
      destroyState: backendActionNotStartedState,
      markDnfState: backendActionNotStartedState,
      loadNextCaseState: backendActionNotStartedState,
      nextCase: none,
      currentCase: none,
      stopwatchState: initialStopwatchState,
      hintActive: false,
      startAfterLoading: StartAfterLoading.NONE,
      intermediateWeightStates: [],
    });
    return trainerAdapter.upsertOne(initialResultsState, trainerState);
  }),
  on(initialLoadResultsSuccess, (trainerState, { trainingSessionId, results }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => recompute(resultsAdapter.setAll(results.map(r => r), { ...resultsState, initialLoadResultsState: backendActionSuccessState })),
    }, trainerState);
  }),
  on(initialLoadResultsFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { initialLoadResultsState: backendActionFailureState(error) }
    }, trainerState);
  }),
  on(create, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { createState: backendActionLoadingState },
    }, trainerState);
  }),
  on(createSuccess, (trainerState, { trainingSessionId, result }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => recompute(resultsAdapter.addOne(result, { ...resultsState, createState: backendActionSuccessState })),
    }, trainerState);
  }),
  on(createFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { createState: backendActionFailureState(error) },
    }, trainerState);
  }),  
  on(destroy, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { destroyState: backendActionLoadingState },
    }, trainerState);
  }),
  on(destroySuccess, (trainerState, { trainingSessionId, resultIds }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => recompute(resultsAdapter.removeMany(resultIds.map(r => r), { ...resultsState, destroyState: backendActionSuccessState })),
    }, trainerState);
  }),
  on(destroyFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { destroyState: backendActionFailureState(error) },
    }, trainerState);
  }),
  on(markDnf, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { markDnfState: backendActionLoadingState },
    }, trainerState);
  }),
  on(markDnfSuccess, (trainerState, { trainingSessionId, resultIds }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => {
        const updates = resultIds.map(id => ({ id, changes: { success: false } }));
        return recompute(resultsAdapter.updateMany(
          updates,
          { ...resultsState, markDnfState: backendActionSuccessState },
        ));
      },
    }, trainerState);
  }),
  on(markDnfFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { markDnfState: backendActionFailureState(error) },
    }, trainerState);
  }),
  on(loadNextCase, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { loadNextCaseState: backendActionLoadingState },
    }, trainerState);
  }),
  on(loadNextCaseSuccess, (trainerState, { trainingSessionId, nextCase }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { nextCase: some(nextCase), loadNextCaseState: backendActionSuccessState },
    }, trainerState);
  }),
  on(loadNextCaseFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { loadNextCaseState: backendActionFailureState(error) },
    }, trainerState);
  }),
  on(setPage, (trainerState, { pageIndex, pageSize }) => {
    return { ...trainerState, pageState: { pageIndex, pageSize } };
  }),
  // Note that stopAndStartStopwatch immediately triggers a stopStopwatch,
  // so we don't have to take care of the regular stopping logic.
  on(stopAndStartStopwatch, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { startAfterLoading: StartAfterLoading.STOPWATCH }
    }, trainerState);
  }),
  // Note that stopAndPauseStopwatch immediately triggers a stopStopwatch,
  // so we don't have to take care of the regular stopping logic.
  on(stopAndPauseStopwatch, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { startAfterLoading: StartAfterLoading.NONE }
    }, trainerState);
  }),
  on(startStopwatch, (trainerState, { trainingSessionId, startUnixMillis }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => ({ ...resultsState, currentCase: resultsState.nextCase, stopwatchState: runningStopwatchState(startUnixMillis), hintActive: false }),
    }, trainerState);
  }),
  // Note that stopAndStartStopwatch immediately triggers a stopStopwatch,
  // so we don't have to take care of the regular stopping logic.
  on(stopAndStartStopwatchDialog, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { startAfterLoading: StartAfterLoading.STOPWATCH_DIALOG }
    }, trainerState);
  }),
  // Note that stopAndPauseStopwatch immediately triggers a stopStopwatch,
  // so we don't have to take care of the regular stopping logic.
  on(stopAndPauseStopwatchDialog, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { startAfterLoading: StartAfterLoading.NONE }
    }, trainerState);
  }),
  on(startStopwatchDialog, (trainerState, { trainingSessionId, startUnixMillis }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => ({ ...resultsState, currentCase: resultsState.nextCase, stopwatchState: runningStopwatchState(startUnixMillis), hintActive: false }),
    }, trainerState);
  }),
  on(stopStopwatchSuccess, (trainerState, { trainingSessionId, durationMillis }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { stopwatchState: stoppedStopwatchState(durationMillis) }
    }, trainerState);
  }),
  on(abandonStopwatchSuccess, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { stopwatchState: notStartedStopwatchState }
    }, trainerState);
  }),
  on(showHint, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { hintActive: true }
    }, trainerState);
  }),
  on(createAlgOverrideSuccess, (trainerState, { trainingSession, algOverride }) => {
    return trainerAdapter.mapOne({
      id: trainingSession.id,
      map: resultsState => addAlgOverrideToResultsState(resultsState, algOverride),
    }, trainerState);
  }),
  on(updateAlgOverrideSuccess, (trainerState, { trainingSession, algOverride }) => {
    return trainerAdapter.mapOne({
      id: trainingSession.id,
      map: resultsState => addAlgOverrideToResultsState(resultsState, algOverride),
    }, trainerState);
  }),
  on(setAlgSuccess, (trainerState, { trainingSession, algOverride }) => {
    return trainerAdapter.mapOne({
      id: trainingSession.id,
      map: resultsState => addAlgOverrideToResultsState(resultsState, algOverride),
    }, trainerState);
  }),
)

const trainerSelectors = trainerAdapter.getSelectors();
const resultsSelectors = resultsAdapter.getSelectors();

export const selectTrainerEntities = trainerSelectors.selectEntities;
export const selectTrainerAll = trainerSelectors.selectAll;
export const selectAllResults = resultsSelectors.selectAll;
export const selectResultsTotal = resultsSelectors.selectTotal;
