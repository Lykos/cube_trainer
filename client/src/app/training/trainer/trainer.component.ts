import { TrainingCase } from '../training-case.model';
import { Sample } from '@utils/sampling';
import { GeneratorType } from '../generator-type.model';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { map, filter, take, shareReplay, distinctUntilChanged } from 'rxjs/operators';
import { TrainingSession } from '../training-session.model';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { MatDialog } from '@angular/material/dialog';
import { now } from '@utils/instant';
import { NewResult } from '../new-result.model';
import { TrainerService } from '../trainer.service';
import { Observable, combineLatest } from 'rxjs';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '@utils/optional';
import { seconds } from '@utils/duration';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { initialLoad } from '@store/training-sessions.actions';
import { create } from '@store/trainer.actions';
import { StopwatchStore } from '../stopwatch.store';
import { Alg } from 'cubing/alg'

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
  providers: [StopwatchStore],
})
export class TrainerComponent implements OnInit, OnDestroy {
  sample?: Sample<TrainingCase>;
  scramble?: Alg;
  trainingSession?: TrainingSession;
  isRunning = false;
  hintActive = false;
  loading$: Observable<boolean>;
  error$: Observable<any>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionSubscription: any;
  private runningSubscription: any;
  private stopSubscription: any;
  private stopwatchLoadingSubscription: any;

  constructor(private readonly trainerService: TrainerService,
              private readonly dialog: MatDialog,
              private readonly store: Store,
              readonly stopwatchStore: StopwatchStore) {
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
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => { this.trainingSession = m; });
    this.stopwatchLoadingSubscription = combineLatest(
      this.stopwatchStore.loading$.pipe(filter(l => l)),
      this.trainingSession$,
    ).subscribe(([_, trainingSession]) => { this.prepareNextCase(trainingSession); })
    this.runningSubscription = this.stopwatchStore.running$.subscribe(() => {
      this.hintActive = false;
    });
    this.stopSubscription = this.stopwatchStore.stop$.subscribe(duration => {
      const newResult: NewResult = {
        caseKey: this.scramble?.toString() || this.sample!.item.caseKey,
        caseName: this.scramble?.toString() || this.sample!.item.caseName,
        numHints: this.hintActive ? 1 : 0,
        timeS: duration.toSeconds(),
        success: true,
      };
      this.store.dispatch(create({ trainingSessionId: this.trainingSession!.id, newResult }));
    });
  }

  ngOnDestroy() {
    this.trainingSessionSubscription?.unsubscribe();
    this.stopSubscription?.unsubscribe();
    this.runningSubscription?.unsubscribe();
    this.stopwatchLoadingSubscription?.unsubscribe();
  }

  private prepareNextCase(trainingSession: TrainingSession) {
    this.sample = undefined;
    this.scramble = undefined;
    switch (trainingSession.trainingSessionType.generatorType) {
      case GeneratorType.Case:
        this.trainerService.randomCase(now(), trainingSession).pipe(take(1)).subscribe(
          sample => {
            this.sample = sample;
            this.stopwatchStore.finishLoading();
          },
          (error) => {
            const context = {
              subject: 'case',
              action: 'selecting',
            };
            this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
          });
        break;
      case GeneratorType.Scramble:
        this.trainerService.randomScramble(now(), trainingSession).pipe(take(1)).subscribe(
          scramble => {
            this.scramble = scramble;
            this.stopwatchStore.finishLoading();
          },
          (error) => {
            const context = {
              subject: 'scramble',
              action: 'generating',
            };
            this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
          });
        break;
    }
  }

  get memoTime() {
    const memoTimeS = this.trainingSession?.memoTimeS;
    return memoTimeS ? seconds(memoTimeS) : undefined;
  }
  get hasStopAndStart(): boolean {
    return true;
  }
}
