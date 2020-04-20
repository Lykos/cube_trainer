import { now } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { InputItem } from './input-item';
import { TrainerService } from './trainer.service';
import { HostListener, Component, OnDestroy } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
import { PartialResult } from './partial-result';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, BehaviorSubject, Subject } from 'rxjs';

enum StopWatchState {
  NotStarted,
  Running,
  Paused
};

@Component({
  selector: 'trainer',
  template: `
<div layout="row" layout-sm="column">
  <div flex>
    <trainer-input [input]="input" [modeId$]="modeId$" [numHints$]="numHintsSubject.asObservable()" *ngIf="input"></trainer-input>
    <div>
      <h2>Time</h2>
      <div> {{duration}} </div>
      <div>
        <ng-container *ngIf="running; else notRunning">
          <button mat-raised-button color="primary" (click)="onStopAndStart()">
            Stop and Start
          </button>
          <button mat-raised-button color="primary" (click)="onStopAndPause()">
            Stop and Pause
          </button>
          <button mat-raised-button color="primary" *ngIf="hintsAvailable" (click)="onHint()">
            Hint
          </button>
        </ng-container>
        <ng-template #notRunning>
          <button mat-raised-button color="primary" (click)="onStart()">
            Start
          </button>
        </ng-template>
      </div>
    </div>
  </div>
  <div flex>
    <results-table [resultEvents$]="resultEventsSubject.asObservable()"></results-table>
  </div>
  <div flex>
    <stats-table [statEvents$]="resultEventsSubject.asObservable()"></stats-table>
  </div>
</div>
`
})
export class TrainerComponent implements OnDestroy {
  duration: Duration = zeroDuration;
  intervalRef: any = undefined;
  state: StopWatchState = StopWatchState.NotStarted;
  input: InputItem | undefined = undefined;
  private readonly numHintsSubject = new BehaviorSubject(0);
  modeId$: Observable<number>;
  resultEventsSubject = new Subject<void>();

  constructor(private readonly trainerService: TrainerService,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p.modeId));
  }

  get hintsAvailable() {
    return this.numHintsSubject.value < this.maxHints;
  }

  get maxHints() {
    return this.input && this.input.hints ? this.input.hints.length : 0;
  }

  get running() {
    return this.state == StopWatchState.Running;
  }

  get notStarted() {
    return this.state == StopWatchState.NotStarted;
  }

  get partialResult(): PartialResult {
    return {
      numHints: this.numHintsSubject.value,
      duration: this.duration!,
      success: true,
    }
  }

  onStart() {
    this.modeId$.subscribe(modeId => {
      this.trainerService.nextInputItemWithCache(modeId).subscribe(input => this.startFor(input));
    });
  }

  startFor(input: InputItem) {
    this.numHintsSubject.next(0);
    this.input = input;
    this.state = StopWatchState.Running;
    const start = now();
    if (this.intervalRef) {
      throw 'Timer started when it was already running.';
    }
    this.intervalRef = setInterval(() => {
      this.duration = start.durationUntil(now());
    });
  }

  stopAnd(onSuccess: () => void) {
    this.stopTimer();
    this.state = StopWatchState.Paused;
    this.modeId$.subscribe(modeId => {
      this.trainerService.stop(modeId, this.input!, this.partialResult).subscribe(r => {
	this.resultEventsSubject.next();
	onSuccess();
      });
    });
  }

  onStopAndPause() {
    this.stopAnd(() => {});
  }

  onStopAndStart() {
    this.stopAnd(() => this.onStart());
  }

  onHint() {
    this.numHintsSubject.next(this.numHintsSubject.value + 1);
  }

  stopTimer() {
    clearInterval(this.intervalRef);
    this.intervalRef = undefined;
  }

  ngOnDestroy() {
    this.stopTimer();
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h' && this.hintsAvailable) {
      this.onHint();
      return;
    }
    if (this.running) {
      this.onStopAndStart();
    } else if (this.notStarted) {
      this.onStart();
    }
  }
}
