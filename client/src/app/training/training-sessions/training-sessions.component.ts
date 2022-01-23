import { Component, OnInit } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { Observable } from 'rxjs';
import { filterPresent } from '@shared/operators';
import { Store } from '@ngrx/store';
import { initialLoad, deleteClick } from '@store/training-sessions.actions';
import { BackendActionError } from '@shared/backend-action-error.model';
import { selectTrainingSessions, selectInitialLoadOrDestroyLoading, selectInitialLoadError } from '@store/training-sessions.selectors';

@Component({
  selector: 'cube-trainer-training-sessions',
  templateUrl: './training-sessions.component.html',
  styleUrls: ['./training-sessions.component.css']
})
export class TrainingSessionsComponent implements OnInit {
  trainingSessions$: Observable<readonly TrainingSession[]>;
  loading$: Observable<boolean>;
  error$: Observable<BackendActionError>;
  columnsToDisplay = ['name', 'numResults', 'use', 'delete'];

  constructor(private readonly store: Store) {
    this.trainingSessions$ = this.store.select(selectTrainingSessions);
    this.loading$ = this.store.select(selectInitialLoadOrDestroyLoading);
    this.error$ = this.store.select(selectInitialLoadError).pipe(filterPresent());
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
  
  onDelete(trainingSession: TrainingSession) {
    this.store.dispatch(deleteClick({ trainingSession }));
  }
}
