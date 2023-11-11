import { selectNextCase } from '@store/trainer.selectors';
import { GeneratorType } from '../generator-type.model';
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { TrainingSession } from '../training-session.model';
import { now } from '@utils/instant';
import { Store } from '@ngrx/store'
import { stopAndStartStopwatchDialog } from '@store/trainer.actions';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';

@Component({
  selector: 'cube-trainer-stopwatch-dialog',
  templateUrl: './stopwatch-dialog.component.html',
  styleUrls: ['./stopwatch-dialog.component.css']
})
export class StopwatchDialogComponent {
  readonly trainingSession: TrainingSession;
  readonly nextCase$: Observable<ScrambleOrSample>;
  
  constructor(@Inject(MAT_DIALOG_DATA) trainingSession: TrainingSession,
	      private readonly store: Store) {
    this.trainingSession = trainingSession;
    this.nextCase$ = this.store.select(selectNextCase).pipe(filterPresent(), tap(c => console.log(c)));
  }

  get hasStopAndStart(): boolean {
    console.log(this.trainingSession.generatorType);
    return this.trainingSession.generatorType === GeneratorType.Case;
  }

  stopAndStart() {
    console.log('stopandstart');
    this.store.dispatch(stopAndStartStopwatchDialog({ trainingSessionId: this.trainingSession.id, stopUnixMillis: now().toUnixMillis() }));
  }
}
