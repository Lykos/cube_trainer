import { Result } from '@training/result.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';

// Results for one specific training session.
export interface ResultsState extends EntityState<Result> {
  readonly trainingSessionId: number;

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
  readonly loadNextCaseState: BackendActionState;
}

export interface PageState {
  readonly pageSize: number;
  readonly pageIndex: number;
}

export enum StopwatchState {
  NotStarted = 'NotStarted',
  Running = 'Running',
  Stopped = 'Stopped',
}

export interface TrainerState extends EntityState<ResultsState> {
  pageState: PageState;
  stopwatchState: StopwatchState;
}
