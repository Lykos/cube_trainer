import { Case } from '../case.model';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { map, filter, take, shareReplay } from 'rxjs/operators';
import { Mode } from '../../modes/mode.model';
import { PartialResult } from '../partial-result.model';
import { TrainerService } from '../trainer.service';
import { ActivatedRoute } from '@angular/router';
import { Observable, combineLatest } from 'rxjs';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '../../utils/optional';
import { selectSelectedMode, selectInitialLoadLoading, selectInitialLoadError } from '../../state/modes.selectors';
import { initialLoad, setSelectedModeId } from '../../state/modes.actions';
import { create } from '../../state/results.actions';
import { StopwatchStore } from '../stopwatch.store';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
  providers: [StopwatchStore],
})
export class TrainerComponent implements OnInit, OnDestroy {
  casee: Case | undefined = undefined;
  numHints = 0;
  mode: Mode | undefined = undefined;
  isRunning = false;
  loading$: Observable<boolean>;
  error$: Observable<any>;

  private mode$: Observable<Mode>
  private modeId$: Observable<number>
  private modeIdSubscription: any;
  private modeSubscription: any;
  private stopSubscription: any;
  private stopwatchLoadingSubscription: any;

  constructor(activatedRoute: ActivatedRoute,
              private readonly trainerService: TrainerService,
              private readonly store: Store,
              readonly stopwatchStore: StopwatchStore) {
    this.modeId$ = activatedRoute.params.pipe(map(p => +p['modeId']));
    this.mode$ = this.store.select(selectSelectedMode).pipe(
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
    this.modeIdSubscription = this.modeId$.subscribe(modeId => {
      this.store.dispatch(setSelectedModeId({ selectedModeId: modeId }));
    });
    this.modeSubscription = this.mode$.subscribe(m => { this.mode = m; });
    this.stopwatchLoadingSubscription = combineLatest(
      this.stopwatchStore.loading$.pipe(filter(l => l)),
      this.mode$,
    ).subscribe(([_, mode]) => { this.prepareNextCase(mode.id); })
    this.stopSubscription = this.stopwatchStore.stop$.subscribe(duration => {
      const partialResult: PartialResult = { numHints: this.numHints, duration, success: true };
      this.store.dispatch(create({ modeId: this.mode.id, casee: this.casee, partialResult }));
    });
  }

  ngOnDestroy() {
    this.modeIdSubscription?.unsubscribe();
    this.modeSubscription?.unsubscribe();
    this.stopSubscription?.unsubscribe();
    this.stopwatchLoadingSubscription?.unsubscribe();
  }

  private prepareNextCase(modeId: number) {
    this.casee = undefined;
    this.trainerService.nextCaseWithCache(modeId).pipe(take(1)).subscribe(casee => {
      this.casee = casee;
      this.stopwatchStore.finishLoading();
    });
  }

  onRunning(isRunning: boolean) {
    this.isRunning = isRunning;
  }

  get maxHints() {
    return this.casee?.hints.length;
  }

  get hasStopAndStart(): boolean {
    return !this.casee?.setup;
  }

  onNumHints(numHints: number) {
    this.numHints = numHints;
  }
}
