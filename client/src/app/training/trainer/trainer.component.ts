import { ShowInputMode } from '../show-input-mode.model';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { distinctUntilChanged } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { TrainingSession } from '../training-session.model';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { Observable, Subscription } from 'rxjs';
import { Store } from '@ngrx/store';
import { ColorScheme } from '../color-scheme.model';
import { selectSelectedTrainingSession } from '@store/training-sessions.selectors';
import { initialLoadSelected } from '@store/trainer.actions';
import { selectCurrentCase, selectNextCase } from '@store/trainer.selectors';
import { selectColorScheme } from '@store/color-scheme.selectors';
import { initialLoad } from '@store/color-scheme.actions';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
})
export class TrainerComponent implements OnInit, OnDestroy {
  trainingSession?: TrainingSession;
  colorScheme?: ColorScheme;
  currentCase$: Observable<ScrambleOrSample>;
  nextCase$: Observable<ScrambleOrSample>;
  colorScheme$: Observable<ColorScheme>;

  private trainingSession$: Observable<TrainingSession>
  private trainingSessionSubscription: Subscription | undefined;

  constructor(private readonly store: Store) {
    this.trainingSession$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filterPresent(),
    );
    this.currentCase$ = this.store.select(selectCurrentCase).pipe(filterPresent());
    this.nextCase$ = this.store.select(selectNextCase).pipe(filterPresent());
    this.colorScheme$ = this.store.select(selectColorScheme).pipe(filterPresent());
  }

  ngOnInit() {
    this.store.dispatch(initialLoadSelected());
    this.trainingSessionSubscription = this.trainingSession$.subscribe(m => {
      this.trainingSession = m;
      // For picture modes, load the color scheme s.t. an empty cube
      // with the right color scheme can be displayed initially.
      if (m.showInputMode == ShowInputMode.Picture) {
	this.store.dispatch(initialLoad());
      }
    });
  }

  ngOnDestroy() {
    this.trainingSessionSubscription?.unsubscribe();
  }
}
