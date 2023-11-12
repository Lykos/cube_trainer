import { Result } from '@training/result.model';
import { Case } from '@training/case.model';
import { ScrambleOrSample } from '@training/scramble-or-sample.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';
import { Optional, none } from '@utils/optional';

export interface LastHintOrDnfInfo {
  readonly daysAfterEpoch: number;
  // Each is a number of days after the unix epoch.
  readonly occurrenceDaysSince: readonly number[];
}

export interface IntermediateWeightState {
  readonly itemsSinceLastOccurrence: number;
  readonly lastOccurrenceUnixMillis: number;
  // Each is a number of days after the unix epoch.
  readonly occurrenceDays: readonly number[];
  readonly totalOccurrences: number;
  readonly lastHintOrDnfInfo: Optional<LastHintOrDnfInfo>;
  readonly recentBadnessesS: readonly number[];
}

export const initialIntermediateWeightState: IntermediateWeightState = {
  itemsSinceLastOccurrence: Infinity,
  lastOccurrenceUnixMillis: -Infinity,
  occurrenceDays: [],
  lastHintOrDnfInfo: none,
  totalOccurrences: 0,
  recentBadnessesS: [],
}

export interface CaseAndIntermediateWeightState {
  readonly casee: Case;
  readonly state: IntermediateWeightState;
}

export enum StartAfterLoading {
  NONE,
  STOPWATCH,
  STOPWATCH_DIALOG,
}

// Results for one specific training session.
export interface ResultsState extends EntityState<Result> {
  readonly trainingSessionId: number;

  readonly initialLoadResultsState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
  readonly markHintState: BackendActionState;
  readonly loadNextCaseState: BackendActionState;

  readonly stopwatchState: StopwatchState;
  readonly hintActive: boolean;
  readonly nextCase: Optional<ScrambleOrSample>;
  readonly currentCase: Optional<ScrambleOrSample>;
  readonly startAfterLoading: StartAfterLoading;
  readonly currentCaseResult: Optional<Result>;

  readonly intermediateWeightStates: readonly CaseAndIntermediateWeightState[];
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
