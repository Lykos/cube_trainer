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
  stopAndStartStopwatch,
  stopAndPauseStopwatch,
  startStopwatch,
  stopStopwatchSuccess,
  showHint,
} from '@store/trainer.actions';
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
import { TrainerState, ResultsState, StopwatchState, notStartedStopwatchState, runningStopwatchState, stoppedStopwatchState } from './trainer.state';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';
import { EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { fromDateString } from '@utils/instant';
import { none, some } from '@utils/optional';

const resultsAdapter: EntityAdapter<Result> = createEntityAdapter<Result>({
  selectId: s => s.id,
  sortComparer: (s, t) => fromDateString(t.createdAt).minusInstant(fromDateString(s.createdAt)).toMillis(),
});

const trainerAdapter: EntityAdapter<ResultsState> = createEntityAdapter<ResultsState>({
  selectId: s => s.trainingSessionId,
});

const initialPageState = {
  pageIndex: 0,
  pageSize: 20,
}

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
      stopwatchState: initialStopwatchState,
      hintActive: false,
      startAfterLoading: false,
    });
    return trainerAdapter.upsertOne(initialResultsState, trainerState);
  }),
  on(initialLoadResultsSuccess, (trainerState, { trainingSessionId, results }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => resultsAdapter.setAll(results.map(r => r), { ...resultsState, initialLoadResultsState: backendActionSuccessState }),
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
      map: resultsState => resultsAdapter.addOne(result, { ...resultsState, createState: backendActionSuccessState }),
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
      map: resultsState => resultsAdapter.removeMany(resultIds.map(r => r), { ...resultsState, destroyState: backendActionSuccessState }),
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
        return resultsAdapter.updateMany(
          updates,
          { ...resultsState, markDnfState: backendActionSuccessState },
        );
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
      changes: { startAfterLoading: true }
    }, trainerState);
  }),
  // Note that stopAndPauseStopwatch immediately triggers a stopStopwatch,
  // so we don't have to take care of the regular stopping logic.
  on(stopAndPauseStopwatch, (trainerState, { trainingSessionId }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { startAfterLoading: false }
    }, trainerState);
  }),
  on(startStopwatch, (trainerState, { trainingSessionId, startUnixMillis }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { stopwatchState: runningStopwatchState(startUnixMillis), hintActive: false }
    }, trainerState);
  }),
  on(stopStopwatchSuccess, (trainerState, { trainingSessionId, durationMillis }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { stopwatchState: stoppedStopwatchState(durationMillis) }
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
