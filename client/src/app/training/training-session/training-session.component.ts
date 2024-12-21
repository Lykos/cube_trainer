import { Component, OnInit, OnDestroy } from '@angular/core';
import { distinctUntilChanged } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { TrainingSession } from '../training-session.model';
import { Observable, Subscription } from 'rxjs';
import { Store } from '@ngrx/store';
import { BackendActionError } from '@shared/backend-action-error.model';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { initialLoadSelected } from '@store/trainer.actions';
import { ResultsTableComponent } from '../results-table/results-table.component';
import { StatsTableComponent } from '../stats-table/stats-table.component';
import { TrainerComponent } from '../trainer/trainer.component';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { AsyncPipe } from '@angular/common';
import { BackendActionLoadErrorComponent } from '../../shared/backend-action-load-error/backend-action-load-error.component';

@Component({
  selector: 'cube-trainer-training-session',
  templateUrl: './training-session.component.html',
  styleUrls: ['./training-session.component.css'],
  imports: [AsyncPipe, BackendActionLoadErrorComponent, ResultsTableComponent, StatsTableComponent, TrainerComponent, MatProgressSpinnerModule],
})
export class TrainingSessionComponent implements OnInit, OnDestroy {
  trainingSession?: TrainingSession;
  loading$: Observable<boolean>;
  error$: Observable<BackendActionError>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionSubscription: Subscription | undefined;

  constructor(private readonly store: Store) {
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filterPresent(),
    );
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.error$ = this.store.select(selectInitialLoadError).pipe(filterPresent());
  }

  ngOnInit() {
    this.store.dispatch(initialLoadSelected());
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => {
      this.trainingSession = m;
    });
  }

  ngOnDestroy() {
    this.trainingSessionSubscription?.unsubscribe();
  }

}
