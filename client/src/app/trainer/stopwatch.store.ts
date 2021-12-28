import { Injectable } from '@angular/core';
import { ComponentStore } from '@ngrx/component-store';
import { now, Instant } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { of, interval } from 'rxjs';
import { switchMap, map, filter, distinctUntilChanged, shareReplay } from 'rxjs/operators';

enum StopwatchRunState {
  LoadingForNotStarted = 'LoadingForNotStarted',
  NotStarted = 'NotStarted',
  LoadingForRunning = 'LoadingForRunning',
  Running = 'Running',
  LoadingForPaused = 'LoadingForPaused',
  Paused = 'Paused',
};

interface RunningStopwatchState {
  readonly runState: StopwatchRunState.Running;
  readonly start: Instant;
}

interface NotStartedStopwatchState {
  readonly runState: StopwatchRunState.LoadingForNotStarted | StopwatchRunState.NotStarted;
}

interface PausedStopwatchState {
  readonly runState: StopwatchRunState.LoadingForPaused | StopwatchRunState.Paused | StopwatchRunState.LoadingForRunning;
  readonly duration: Duration;
}

type StopwatchState = NotStartedStopwatchState | RunningStopwatchState | PausedStopwatchState;

const initialState: StopwatchState = {
  runState: StopwatchRunState.LoadingForNotStarted
};

function isLoading(runState: StopwatchRunState) {
  return runState === StopwatchRunState.LoadingForNotStarted || runState === StopwatchRunState.LoadingForRunning || runState === StopwatchRunState.LoadingForPaused;
}

function isNotStarted(runState: StopwatchRunState) {
  return runState === StopwatchRunState.LoadingForNotStarted || runState === StopwatchRunState.NotStarted;
}

@Injectable()
export class StopwatchStore extends ComponentStore<StopwatchState> {
  constructor() {
    super(initialState);
  }

  private newRunningState(): RunningStopwatchState {
    return {
      runState: StopwatchRunState.Running,
      start: now(),
    };
  }

  readonly start = this.updater((state) => {
    if (state.runState !== StopwatchRunState.NotStarted && state.runState !== StopwatchRunState.Paused) {
      throw new Error(`cannot start stopwatch in state ${state.runState}`);
    }
    return this.newRunningState();
  });

  readonly stopAndPause = this.updater((state) => {
    if (state.runState !== StopwatchRunState.Running) {
      throw new Error(`cannot stop stopwatch in state ${state.runState}`);
    }
    return {
      runState: StopwatchRunState.LoadingForPaused,
      duration: state.start.durationUntil(now()),
    };
  });

  readonly stopAndStart = this.updater((state) => {
    if (state.runState !== StopwatchRunState.Running) {
      throw new Error(`cannot stop stopwatch in state ${state.runState}`);
    }
    return {
      runState: StopwatchRunState.LoadingForRunning,
      duration: state.start.durationUntil(now()),
    };
  });

  readonly finishLoading = this.updater((state) => {
    switch (state.runState) {
      case StopwatchRunState.LoadingForNotStarted:
        return {
          runState: StopwatchRunState.NotStarted,
        };
      case StopwatchRunState.LoadingForPaused:
        return {
          ...state,
          runState: StopwatchRunState.Paused,
        };
      case StopwatchRunState.LoadingForRunning:
        return this.newRunningState();
      default:
        throw new Error(`cannot finish loading in state ${state.runState}`);
    }
  });

  readonly duration$ = this.select(state => state).pipe(
    switchMap(state => {
      switch (state.runState) {
        case StopwatchRunState.NotStarted:
        case StopwatchRunState.LoadingForNotStarted:
          return of(zeroDuration);
        case StopwatchRunState.LoadingForRunning:
        case StopwatchRunState.LoadingForPaused:
        case StopwatchRunState.Paused:
          return of(state.duration);
        case StopwatchRunState.Running:
          return interval(10).pipe(map(() => state.start.durationUntil(now())));
      }
    }),
  );

  readonly stop$ = this.select(state => state).pipe(
    filter(state => state.runState === StopwatchRunState.LoadingForPaused || state.runState === StopwatchRunState.LoadingForRunning),
    map(state => (state as PausedStopwatchState).duration),
  );

  readonly loading$ = this.select(state => isLoading(state.runState)).pipe(
    distinctUntilChanged(),
    shareReplay(),
  );

  readonly running$ = this.select(state => state.runState === StopwatchRunState.Running).pipe(
    distinctUntilChanged(),
    shareReplay(),
  );

  readonly notStarted$ = this.select(state => isNotStarted(state.runState)).pipe(
    distinctUntilChanged(),
    shareReplay(),
  );
}
