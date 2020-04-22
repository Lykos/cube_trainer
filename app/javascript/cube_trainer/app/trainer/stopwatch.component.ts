import { now } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { InputItem } from './input-item';
import { TrainerService } from './trainer.service';
import { HostListener, Component, OnInit, OnDestroy, Input, Output, EventEmitter } from '@angular/core';
import { PartialResult } from './partial-result';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable } from 'rxjs';

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
export class StopwatchComponent implements OnInit, OnDestroy {
  @Input()
  private modeId$!: Observable<number>;

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
  private intervalRef: any = undefined;
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
    this.modeId$.subscribe(modeId => {
      this.trainerService.nextInputItemWithCache(modeId).subscribe(input => this.startFor(input));
    });
  }

  startFor(input: InputItem) {
    this.numHints_ = 0;
    this.numHints.emit(this.numHints_);
    this.maxHints = input.hints ? input.hints.length : 0;
    this.input = input;
    this.inputItem.emit(input);
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
      this.trainerService.stop(modeId, this.input!, this.partialResult).subscribe(() => {
	console.log('saved');
	this.resultSaved.emit();
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
    if (this.hintsAvailable) {
      ++this.numHints_;
      this.numHints.emit(this.numHints_);
    }
  }

  stopTimer() {
    clearInterval(this.intervalRef);
    this.intervalRef = undefined;
  }

  ngOnInit() {
    this.modeId$.subscribe(modeId => {
      this.trainerService.prewarmInputItemsCache(modeId);
    });
  }

  ngOnDestroy() {
    this.stopTimer();
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
