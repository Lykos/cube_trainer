import { Result } from '@training/result.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';
import { Optional } from '@utils/optional';

// Results for one specific training session.
export interface ResultsState extends EntityState<Result> {
  readonly trainingSessionId: number;

  readonly initialLoadResultsState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
  readonly loadNextCaseState: BackendActionState;

  readonly stopwatchState: StopwatchState;
  readonly hintActive: boolean;
  readonly nextCase: Optional<ScrambleOrSample>;
  readonly startAfterLoading: boolean;
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

export function isNotStarted(stopwatchState: StopwatchState): stopwatchState is NotStartedStopwatchState {
  return stopwatchState.tag === 'not started';
}

export function isRunning(stopwatchState: StopwatchState): stopwatchState is RunningStopwatchState {
  return stopwatchState.tag === 'running';
}

export function isStopped(stopwatchState: StopwatchState): stopwatchState is StoppedStopwatchState {
  return stopwatchState.tag === 'stopped';
}

export interface TrainerState extends EntityState<ResultsState> {
  readonly pageState: PageState;
}
