import { Component, OnInit } from '@angular/core';
import { TrainingSessionSummary } from '../training-session-summary.model';
import { Observable } from 'rxjs';
import { filterPresent } from '@shared/operators';
import { Store } from '@ngrx/store';
import { initialLoad, deleteClick } from '@store/training-sessions.actions';
import { BackendActionError } from '@shared/backend-action-error.model';
import { selectTrainingSessionSummaries, selectInitialLoadOrDestroyLoading, selectInitialLoadError } from '@store/training-sessions.selectors';

@Component({
  selector: 'cube-trainer-training-sessions',
  templateUrl: './training-sessions.component.html',
  styleUrls: ['./training-sessions.component.css']
})
export class TrainingSessionsComponent implements OnInit {
  trainingSessions$: Observable<readonly TrainingSessionSummary[]>;
  loading$: Observable<boolean>;
  error$: Observable<BackendActionError>;
  columnsToDisplay = ['name', 'numResults', 'use', 'delete'];

  constructor(private readonly store: Store) {
    this.trainingSessions$ = this.store.select(selectTrainingSessionSummaries);
    this.loading$ = this.store.select(selectInitialLoadOrDestroyLoading);
    this.error$ = this.store.select(selectInitialLoadError).pipe(filterPresent());
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
  
  onDelete(trainingSession: TrainingSessionSummary) {
    this.store.dispatch(deleteClick({ trainingSession }));
  }
}
