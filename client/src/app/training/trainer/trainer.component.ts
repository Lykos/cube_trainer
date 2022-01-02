import { TrainingCase } from '../training-case.model';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { map, filter, take, shareReplay, distinctUntilChanged } from 'rxjs/operators';
import { TrainingSession } from '../training-session.model';
import { now } from '@utils/instant';
import { PartialResult } from '../partial-result.model';
import { TrainerService } from '../trainer.service';
import { ActivatedRoute } from '@angular/router';
import { Observable, combineLatest } from 'rxjs';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '@utils/optional';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { initialLoad, setSelectedTrainingSessionId } from '@store/training-sessions.actions';
import { create } from '@store/results.actions';
import { StopwatchStore } from '../stopwatch.store';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
  providers: [StopwatchStore],
})
export class TrainerComponent implements OnInit, OnDestroy {
  trainingCase?: TrainingCase;
  trainingSession?: TrainingSession;
  isRunning = false;
  hintActive = false;
  loading$: Observable<boolean>;
  error$: Observable<any>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionId$: Observable<number>
  private trainingSessionIdSubscription: any;
  private trainingSessionSubscription: any;
  private runningSubscription: any;
  private stopSubscription: any;
  private stopwatchLoadingSubscription: any;

  constructor(activatedRoute: ActivatedRoute,
              private readonly trainerService: TrainerService,
              private readonly store: Store,
              readonly stopwatchStore: StopwatchStore) {
    this.trainingSessionId$ = activatedRoute.params.pipe(map(p => +p['trainingSessionId']));
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filter(hasValue),
      map(forceValue),
      shareReplay(),
    );
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.error$ = this.store.select(selectInitialLoadError).pipe(
      filter(hasValue),
      map(forceValue),
    );
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
    this.trainingSessionIdSubscription = this.trainingSessionId$.subscribe(trainingSessionId => {
      this.store.dispatch(setSelectedTrainingSessionId({ selectedTrainingSessionId: trainingSessionId }));
    });
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => { this.trainingSession = m; });
    this.stopwatchLoadingSubscription = combineLatest(
      this.stopwatchStore.loading$.pipe(filter(l => l)),
      this.trainingSession$,
    ).subscribe(([_, trainingSession]) => { this.prepareNextCase(trainingSession); })
    this.runningSubscription = this.stopwatchStore.running$.subscribe(() => {
      this.hintActive = false;
    });
    this.stopSubscription = this.stopwatchStore.stop$.subscribe(duration => {
      const partialResult: PartialResult = { numHints: this.hintActive ? 1 : 0, duration, success: true };
      this.store.dispatch(create({ trainingSessionId: this.trainingSession!.id, trainingCase: this.trainingCase!, partialResult }));
    });
  }

  ngOnDestroy() {
    this.trainingSessionIdSubscription?.unsubscribe();
    this.trainingSessionSubscription?.unsubscribe();
    this.stopSubscription?.unsubscribe();
    this.runningSubscription?.unsubscribe();
    this.stopwatchLoadingSubscription?.unsubscribe();
  }

  private prepareNextCase(trainingSession: TrainingSession) {
    this.trainingCase = undefined;
    this.trainerService.randomCase(now(), trainingSession).pipe(take(1)).subscribe(trainingCase => {
      this.trainingCase = trainingCase;
      this.stopwatchStore.finishLoading();
    });
  }

  get hasStopAndStart(): boolean {
    return true;
  }
}
