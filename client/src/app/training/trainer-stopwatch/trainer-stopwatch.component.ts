import { GeneratorType } from '../generator-type.model';
import { Duration, zeroDuration, millis, seconds } from '@utils/duration';
import { fromUnixMillis, now } from '@utils/instant';
import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { selectStopwatchState, selectStopwatchRunning, selectNextCaseReady } from '@store/trainer.selectors';
import { startStopwatch, stopAndPauseStopwatch, stopAndStartStopwatch } from '@store/trainer.actions';
import { Observable, interval, of, Subscription } from 'rxjs';
import { TrainingSession } from '../training-session.model';
import { map, switchMap } from 'rxjs/operators';
import { Store } from '@ngrx/store'

@Component({
  selector: 'cube-trainer-trainer-stopwatch',
  templateUrl: './trainer-stopwatch.component.html',
  styleUrls: ['./trainer-stopwatch.component.css']
})
export class TrainerStopwatchComponent implements OnInit, OnDestroy {
  @Input()
  trainingSession?: TrainingSession;

  duration$: Observable<Duration>;
  running$: Observable<boolean>;
  nextCaseReady$: Observable<boolean>;

  running: boolean | undefined;
  nextCaseReady: boolean | undefined;

  runningSubscription: Subscription | undefined;
  nextCaseReadySubscription: Subscription | undefined;
  
  constructor(private readonly store: Store) {
    this.duration$ = this.store.select(selectStopwatchState).pipe(
      switchMap(state => {
        switch (state.tag) {
          case 'not started':
            return of(zeroDuration);
          case 'stopped':
            return of(millis(state.durationMillis));
          case 'running': {
            const start = fromUnixMillis(state.startUnixMillis);
            return interval(10).pipe(map(() => now().minusInstant(start)));
          }
        }
      }),
    );
    this.running$ = this.store.select(selectStopwatchRunning);
    this.nextCaseReady$ = this.store.select(selectNextCaseReady);
  }

  ngOnInit() {
    this.runningSubscription = this.running$.subscribe(running => { this.running = running; });
    this.nextCaseReadySubscription = this.nextCaseReady$.subscribe(nextCaseReady => { this.nextCaseReady = nextCaseReady; });
  }

  ngOnDestroy() {
    this.runningSubscription?.unsubscribe();
    this.nextCaseReadySubscription?.unsubscribe();
  }

  onStart(trainingSession: TrainingSession) {
    this.store.dispatch(startStopwatch({ trainingSessionId: trainingSession.id, startUnixMillis: now().toUnixMillis() }));
  }

  onStopAndPause(trainingSession: TrainingSession) {
    this.store.dispatch(stopAndPauseStopwatch(this.stopProps(trainingSession)));
  }

  onStopAndStart(trainingSession: TrainingSession) {
    this.store.dispatch(stopAndStartStopwatch(this.stopProps(trainingSession)));
  }

  private stopProps(trainingSession: TrainingSession) {
    return { trainingSessionId: trainingSession.id, stopUnixMillis: now().toUnixMillis() };
  }
  
  get memoTime() {
    const memoTimeS = this.trainingSession?.memoTimeS;
    return memoTimeS ? seconds(memoTimeS) : undefined;
  }

  get hasStopAndStart(): boolean {
    return this.trainingSession?.generatorType === GeneratorType.Case;
  }
}
