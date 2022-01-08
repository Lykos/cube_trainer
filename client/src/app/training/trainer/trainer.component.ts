import { Component, OnInit, OnDestroy } from '@angular/core';
import { map, filter, shareReplay, distinctUntilChanged } from 'rxjs/operators';
import { TrainingSession } from '../training-session.model';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { Observable, Subscription } from 'rxjs';
import { Store } from '@ngrx/store';
import { hasValue, forceValue } from '@utils/optional';
import { BackendActionError } from '@shared/backend-action-error.model';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { initialLoadSelected } from '@store/trainer.actions';
import { selectNextCase, selectHintActive } from '@store/trainer.selectors';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
})
export class TrainerComponent implements OnInit, OnDestroy {
  trainingSession?: TrainingSession;
  loading$: Observable<boolean>;
  scrambleOrSample$: Observable<ScrambleOrSample>;
  hintActive$: Observable<{ value: boolean }>;
  error$: Observable<BackendActionError>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionSubscription: Subscription | undefined;

  constructor(private readonly store: Store) {
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filter(hasValue),
      map(forceValue),
      shareReplay(),
    );
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.scrambleOrSample$ = this.store.select(selectNextCase).pipe(filter(hasValue), map(forceValue));
    this.hintActive$ = this.store.select(selectHintActive).pipe(map(value => ({ value })));
    this.error$ = this.store.select(selectInitialLoadError).pipe(
      filter(hasValue),
      map(forceValue),
    );
  }

  ngOnInit() {
    this.store.dispatch(initialLoadSelected());
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => { this.trainingSession = m; });
  }

  ngOnDestroy() {
    this.trainingSessionSubscription?.unsubscribe();
  }
}
