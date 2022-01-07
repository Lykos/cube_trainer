import { Result } from '@training/result.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';
import { Optional } from '@utils/optional';

// Results for one specific training session.
export interface ResultsState extends EntityState<Result> {
  readonly trainingSessionId: number;

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
  readonly loadNextCaseState: BackendActionState;

  readonly stopwatchState: StopwatchState;
  readonly hintActive: boolean;
  readonly nextCase: Optional<ScrambleOrSample>;
}

export interface PageState {
  readonly pageSize: number;
  readonly pageIndex: number;
}

export interface NotStartedStopwatchState {
  readonly tag: 'not started';
}

export const notStartedStopwatchState: NotStartedStopwatchState = {
  tag: 'not started',
};

export interface RunningStopwatchState {
  readonly tag: 'running';
  readonly startUnixMillis: number;
}

export function runningStopwatchState(startUnixMillis: number): RunningStopwatchState {
  return {
    tag: 'running',
    startUnixMillis,
  };
}

export interface StoppedStopwatchState {
  readonly tag: 'stopped';
  readonly durationMillis: number;
}

export function stoppedStopwatchState(durationMillis: number): StoppedStopwatchState {
  return {
    tag: 'stopped',
    durationMillis,
  };
}

export type StopwatchState = NotStartedStopwatchState | RunningStopwatchState | StoppedStopwatchState;

export interface TrainerState extends EntityState<ResultsState> {
  readonly pageState: PageState;
}
