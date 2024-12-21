import { selectNextCase, selectStopwatchState } from '@store/trainer.selectors';
import { GeneratorType } from '../generator-type.model';
import { Component, Inject } from '@angular/core';
import { seconds } from '@utils/duration';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { TrainingSession } from '../training-session.model';
import { now, fromUnixMillis } from '@utils/instant';
import { Store } from '@ngrx/store'
import { stopAndStartStopwatchDialog } from '@store/trainer.actions';
import { Observable, of, timer } from 'rxjs';
import { tap, switchMap, mapTo } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { SharedModule } from '@shared/shared.module';
import { TrainerInputComponent } from '../trainer-input/trainer-input.component';
import { NgClass } from '@angular/common';

@Component({
  selector: 'cube-trainer-stopwatch-dialog',
  templateUrl: './stopwatch-dialog.component.html',
  styleUrls: ['./stopwatch-dialog.component.css'],
  imports: [SharedModule, TrainerInputComponent, NgClass],
})
export class StopwatchDialogComponent {
  readonly isPostMemoTime$: Observable<boolean>;
  readonly nextCase$: Observable<ScrambleOrSample>;

  readonly trainingSession: TrainingSession;

  constructor(@Inject(MAT_DIALOG_DATA) trainingSession: TrainingSession,
	      private readonly store: Store,
	      private readonly dialogRef: MatDialogRef<StopwatchDialogComponent>) {
    this.trainingSession = trainingSession;
    this.nextCase$ = this.store.select(selectNextCase).pipe(filterPresent(), tap(c => console.log(c)));
    this.isPostMemoTime$ = this.store.select(selectStopwatchState).pipe(
      switchMap(state => {
        switch (state.tag) {
          case 'not started':
            return of(false);
          case 'stopped':
            return of(false);
          case 'running': {
	    const trainingSession = this.trainingSession;
	    if (trainingSession.generatorType !== GeneratorType.Scramble) {
	      return of(false);
	    }
	    const memoTimeS = trainingSession.memoTimeS;
	    if (!memoTimeS) {
	      return of(false);
	    }
            const start = fromUnixMillis(state.startUnixMillis);
	    const remainingMemoTime = seconds(memoTimeS).minus(now().minusInstant(start));
            return timer(remainingMemoTime.toMillis()).pipe(mapTo(true));
          }
        }
      }),
    );
  }

  get hasStopAndStart(): boolean {
    return this.trainingSession.generatorType === GeneratorType.Case;
  }

  get showTrainerInput(): boolean {
    return this.trainingSession.generatorType === GeneratorType.Case;
  }

  stopAndStart() {
    if (this.hasStopAndStart) {
      this.store.dispatch(stopAndStartStopwatchDialog({ trainingSessionId: this.trainingSession.id, stopUnixMillis: now().toUnixMillis() }));
    } else {
      this.dialogRef.close(true);
    }
  }
}
