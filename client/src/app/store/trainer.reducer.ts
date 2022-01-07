import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, markDnf, markDnfSuccess, markDnfFailure, setPage } from '@store/trainer.actions';
import { Result } from '@training/result.model';
import { TrainerState, ResultsState, StopwatchState } from './trainer.state';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';
import { EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { fromDateString } from '@utils/instant';

const resultsAdapter: EntityAdapter<Result> = createEntityAdapter<Result>({
  selectId: s => s.id,
  sortComparer: (s, t) => fromDateString(t.createdAt).minusInstant(fromDateString(s.createdAt)).toMillis(),
});

const trainerAdapter: EntityAdapter<ResultsState> = createEntityAdapter<ResultsState>({
  selectId: s => s.trainingSessionId,
});

const initialPageState = {
  pageIndex: 0,
  pageSize: 100,
}

const initialStopwatchState = StopwatchState.NotStarted;

const initialTrainerState: TrainerState = trainerAdapter.getInitialState({
  pageState: initialPageState,
  stopwatchState: initialStopwatchState,
});

export const trainerReducer = createReducer(
  initialTrainerState,
  on(initialLoad, (trainerState, { trainingSessionId }) => {
    const initialResultsState = resultsAdapter.getInitialState({
      trainingSessionId,
      initialLoadState: backendActionLoadingState,
      createState: backendActionNotStartedState,
      destroyState: backendActionNotStartedState,
      markDnfState: backendActionNotStartedState,
      loadNextCaseState: backendActionNotStartedState,
    });
    return trainerAdapter.upsertOne(initialResultsState, trainerState);
  }),
  on(initialLoadSuccess, (trainerState, { trainingSessionId, results }) => {
    return trainerAdapter.mapOne({
      id: trainingSessionId,
      map: resultsState => resultsAdapter.setAll(results.map(r => r), { ...resultsState, initialLoadState: backendActionSuccessState }),
    }, trainerState);
  }),
  on(initialLoadFailure, (trainerState, { trainingSessionId, error }) => {
    return trainerAdapter.updateOne({
      id: trainingSessionId,
      changes: { initialLoadState: backendActionFailureState(error) }
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
  on(setPage, (trainerState, { pageIndex, pageSize }) => {
    return { ...trainerState, pageState: { pageIndex, pageSize } };
  }),
)

const trainerSelectors = trainerAdapter.getSelectors();
const resultsSelectors = resultsAdapter.getSelectors();

export const selectTrainerEntities = trainerSelectors.selectEntities;
export const selectAllResults = resultsSelectors.selectAll;
export const selectResultsTotal = resultsSelectors.selectTotal;
