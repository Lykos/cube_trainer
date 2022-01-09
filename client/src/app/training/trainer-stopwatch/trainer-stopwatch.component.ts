import { GeneratorType } from '../generator-type.model';
import { Duration, zeroDuration, millis, seconds } from '@utils/duration';
import { fromUnixMillis, now } from '@utils/instant';
import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { selectStopwatchState, selectStopwatchRunning, selectNextCaseReady } from '@store/trainer.selectors';
import { startStopwatch, stopAndPauseStopwatch, stopAndStartStopwatch } from '@store/trainer.actions';
import { Observable, interval, of, Subscription } from 'rxjs';
import { TrainingSession } from '../training-session.model';
import { map, switchMap, tap } from 'rxjs/operators';
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
    console.log('trainer stopwatch constructor');
    this.duration$ = this.store.select(selectStopwatchState).pipe(
      switchMap(state => {
        console.log('stopwatch state', state);
        switch (state.tag) {
          case 'not started':
            return of(zeroDuration);
          case 'stopped':
            return of(millis(state.durationMillis));
          case 'running': {
            const start = fromUnixMillis(state.startUnixMillis);
            console.log('start', start);
            return interval(10).pipe(map(() => { console.log('now', now()); return now().minusInstant(start); }));
          }
        }
      }),
    );
    this.running$ = this.store.select(selectStopwatchRunning);
    this.nextCaseReady$ = this.store.select(selectNextCaseReady).pipe(tap(r => { console.log('ready', r); }));
  }

  ngOnInit() {
    console.log('trainer stopwatch ngInit');
    this.runningSubscription = this.running$.subscribe(running => { this.running = running; });
    this.nextCaseReadySubscription = this.nextCaseReady$.subscribe(nextCaseReady => { this.nextCaseReady = nextCaseReady; });
  }

  ngOnDestroy() {
    this.runningSubscription?.unsubscribe();
    this.nextCaseReadySubscription?.unsubscribe();
  }

  onStart() {
    console.log('onStart');
    this.store.dispatch(startStopwatch({ trainingSessionId: this.trainingSession!.id, startUnixMillis: now().toUnixMillis() }));
  }

  onStopAndPause() {
    console.log('onStopAndPause');
    this.store.dispatch(stopAndPauseStopwatch(this.stopProps));
  }

  onStopAndStart() {
    console.log('onStopAndStart');
    this.store.dispatch(stopAndStartStopwatch(this.stopProps));
  }

  private get stopProps() {
    return { trainingSessionId: this.trainingSession!.id, stopUnixMillis: now().toUnixMillis() };
  }
  
  get memoTime() {
    const memoTimeS = this.trainingSession?.memoTimeS;
    return memoTimeS ? seconds(memoTimeS) : undefined;
  }

  get hasStopAndStart(): boolean {
    return this.trainingSession?.trainingSessionType?.generatorType === GeneratorType.Case;
  }
}
