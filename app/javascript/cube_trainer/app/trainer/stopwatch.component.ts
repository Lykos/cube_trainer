import { now } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { InputItem } from './input-item';
import { Mode } from '../modes/mode';
import { TrainerService } from './trainer.service';
import { HostListener, Component, OnDestroy, Input, Output, EventEmitter } from '@angular/core';
import { PartialResult } from './partial-result';
import { interval } from 'rxjs';

enum StopWatchState {
  NotStarted,
  Running,
  Paused
};

@Component({
  selector: 'stopwatch',
  template: `
<div class="stopwatch">
  <h2>Time</h2>
  <div class="stopwatch-time"> {{duration}} </div>
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
`,
  styles: [`
.stopwatch-time {
  font-size: xxx-large;
}
`]
})
export class StopwatchComponent implements OnDestroy {
  @Input()
  private mode!: Mode;

  @Output()
  private inputItem: EventEmitter<InputItem> = new EventEmitter();

  @Output()
  private resultSaved: EventEmitter<void> = new EventEmitter();

  @Output()
  private numHints: EventEmitter<number> = new EventEmitter();

  private input: InputItem | undefined = undefined;
  private numHints_ = 0;
  private maxHints = 0;
  private duration: Duration = zeroDuration;
  private intervalSubscription: any = undefined;
  private state: StopWatchState = StopWatchState.NotStarted;

  constructor(private readonly trainerService: TrainerService) {}

  get hintsAvailable() {
    return this.numHints_ < this.maxHints;
  }

  get running() {
    return this.state == StopWatchState.Running;
  }

  get notStarted() {
    return this.state == StopWatchState.NotStarted;
  }

  get partialResult(): PartialResult {
    return {
      numHints: this.numHints_,
      duration: this.duration!,
      success: true,
    }
  }

  onStart() {
    this.trainerService.nextInputItemWithCache(this.mode.id).subscribe(input => this.startFor(input));
  }

  startFor(input: InputItem) {
    this.numHints_ = 0;
    this.numHints.emit(this.numHints_);
    this.maxHints = input.hints ? input.hints.length : 0;
    this.input = input;
    this.inputItem.emit(input);
    this.state = StopWatchState.Running;
    const start = now();
    if (this.intervalSubscription) {
      throw 'Timer started when it was already running.';
    }
    this.intervalSubscription = interval(10).subscribe(() => {
      this.duration = start.durationUntil(now());
    });
  }

  stopAnd(onSuccess: () => void) {
    this.stopInterval();
    this.state = StopWatchState.Paused;
    this.trainerService.stop(this.mode.id, this.input!, this.partialResult).subscribe(() => {
      this.resultSaved.emit();
      onSuccess();
    });
  }

  onStopAndPause() {
    this.stopAnd(() => {});
  }

  onStopAndStart() {
    this.stopAnd(() => this.onStart());
  }

  onHint() {
    if (this.hintsAvailable) {
      ++this.numHints_;
      this.numHints.emit(this.numHints_);
    }
  }

  stopInterval() {
    if (!this.intervalSubscription) {
      return;
    }
    this.intervalSubscription.unsubscribe();
    this.intervalSubscription = undefined;
  }

  ngOnDestroy() {
    this.stopInterval();
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h') {
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
