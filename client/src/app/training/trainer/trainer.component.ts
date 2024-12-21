import { ShowInputMode } from '../show-input-mode.model';
import { some, none } from '@utils/optional';
import { Component, OnInit, OnDestroy } from '@angular/core';
import { distinctUntilChanged, map } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { TrainingSession } from '../training-session.model';
import { TrainingCase } from '../training-case.model';
import { ScrambleOrSample, isSample } from '../scramble-or-sample.model';
import { Observable, Subscription } from 'rxjs';
import { Store } from '@ngrx/store';
import { ColorScheme } from '../color-scheme.model';
import { selectSelectedTrainingSession } from '@store/training-sessions.selectors';
import { selectCurrentCase, selectNextCase } from '@store/trainer.selectors';
import { selectColorScheme } from '@store/color-scheme.selectors';
import { initialLoad } from '@store/color-scheme.actions';
import { SharedModule } from '@shared/shared.module';
import { TrainerInputComponent } from '../trainer-input/trainer-input.component';
import { TrainerStopwatchComponent } from '../trainer-stopwatch/trainer-stopwatch.component';
import { HintComponent } from '../hint/hint.component';

@Component({
  selector: 'cube-trainer-trainer',
  templateUrl: './trainer.component.html',
  imports: [SharedModule, TrainerInputComponent, TrainerStopwatchComponent, HintComponent],
})
export class TrainerComponent implements OnInit, OnDestroy {
  trainingSession?: TrainingSession;
  colorScheme?: ColorScheme;
  currentCase$: Observable<ScrambleOrSample>;
  currentTrainingCase$: Observable<TrainingCase>;
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
    this.currentTrainingCase$ = this.store.select(selectCurrentCase).pipe(filterPresent(), map(c => isSample(c) ? some(c.sample.item) : none), filterPresent());
    this.nextCase$ = this.store.select(selectNextCase).pipe(filterPresent());
    this.colorScheme$ = this.store.select(selectColorScheme).pipe(filterPresent());
  }

  ngOnInit() {
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
