import { Component, OnInit, OnDestroy } from '@angular/core';
import { distinctUntilChanged } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { TrainingSession } from '../training-session.model';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { Observable, Subscription } from 'rxjs';
import { Store } from '@ngrx/store';
import { BackendActionError } from '@shared/backend-action-error.model';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { initialLoadSelected } from '@store/trainer.actions';
import { selectNextCase } from '@store/trainer.selectors';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
})
export class TrainerComponent implements OnInit, OnDestroy {
  trainingSession?: TrainingSession;
  loading$: Observable<boolean>;
  scrambleOrSample$: Observable<ScrambleOrSample>;
  error$: Observable<BackendActionError>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionSubscription: Subscription | undefined;

  constructor(private readonly store: Store) {
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filterPresent(),
    );
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.scrambleOrSample$ = this.store.select(selectNextCase).pipe(filterPresent());
    this.error$ = this.store.select(selectInitialLoadError).pipe(filterPresent());
  }

  ngOnInit() {
    this.store.dispatch(initialLoadSelected());
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => { this.trainingSession = m; });
  }

  ngOnDestroy() {
    this.trainingSessionSubscription?.unsubscribe();
  }
}
