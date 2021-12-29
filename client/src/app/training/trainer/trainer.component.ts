import { Case } from '../case.model';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { map, filter, take, shareReplay, distinctUntilChanged } from 'rxjs/operators';
import { TrainingSession } from '../training-session.model';
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
  casee?: Case;
  numHints = 0;
  trainingSession?: TrainingSession;
  isRunning = false;
  loading$: Observable<boolean>;
  error$: Observable<any>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionId$: Observable<number>
  private trainingSessionIdSubscription: any;
  private trainingSessionSubscription: any;
  private stopSubscription: any;
  private stopwatchLoadingSubscription: any;

  constructor(activatedRoute: ActivatedRoute,
              private readonly trainerService: TrainerService,
              private readonly store: Store,
              readonly stopwatchStore: StopwatchStore) {
    this.trainingSessionId$ = activatedRoute.params.pipe(map(p => +p['trainingSessionId']));
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
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
      this.trainingSession$.pipe(map(trainingSession => trainingSession.id), distinctUntilChanged()),
    ).subscribe(([_, trainingSessionId]) => { this.prepareNextCase(trainingSessionId); })
    this.stopSubscription = this.stopwatchStore.stop$.subscribe(duration => {
      const partialResult: PartialResult = { numHints: this.numHints, duration, success: true };
      this.store.dispatch(create({ trainingSessionId: this.trainingSession!.id, casee: this.casee!, partialResult }));
    });
  }

  ngOnDestroy() {
    this.trainingSessionIdSubscription?.unsubscribe();
    this.trainingSessionSubscription?.unsubscribe();
    this.stopSubscription?.unsubscribe();
    this.stopwatchLoadingSubscription?.unsubscribe();
  }

  private prepareNextCase(trainingSessionId: number) {
    this.casee = undefined;
    this.trainerService.nextCaseWithCache(trainingSessionId).pipe(take(1)).subscribe(casee => {
      this.casee = casee;
      this.stopwatchStore.finishLoading();
    });
  }

  onRunning(isRunning: boolean) {
    this.isRunning = isRunning;
  }

  get maxHints() {
    return this.casee?.alg ? 1 : 0;
  }

  get hasStopAndStart(): boolean {
    return true;
  }

  onNumHints(numHints: number) {
    this.numHints = numHints;
  }
}
