import { GeneratorType } from '../generator-type.model';
import { Duration, zeroDuration, millis, seconds } from '@utils/duration';
import { fromUnixMillis, now } from '@utils/instant';
import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { selectStopwatchState, selectStopwatchRunning, selectNextCaseReady } from '@store/trainer.selectors';
import { startStopwatch, stopStopwatch, stopAndStartStopwatch } from '@store/trainer.actions';
import { Observable, interval, of } from 'rxjs';
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

  runningSubscription: { unsubscribe: () => void } | undefined;
  nextCaseReadySubscription: { unsubscribe: () => void } | undefined;
  
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

  onStart() {
    this.store.dispatch(startStopwatch({ trainingSessionId: this.trainingSession!.id, startUnixMillis: now().toUnixMillis() }));
  }

  onStopAndPause() {
    this.store.dispatch(stopStopwatch(this.stopProps));
  }

  onStopAndStart() {
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
