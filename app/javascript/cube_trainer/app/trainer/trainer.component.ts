import { now } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { InputItem } from './input_item';
import { TrainerService } from './trainer.service';
import { Component, OnDestroy } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subject } from 'rxjs';

enum StopWatchState {
  NotStarted,
  Running,
  Paused
};

@Component({
  selector: 'trainer',
  template: `
<div class="container">
  <trainer-input [input]=input></trainer-input>
  <mat-card>
    <mat-card-title>Time</mat-card-title>
    <mat-card-content> {{duration}} </mat-card-content>
    <mat-card-actions>
      <ng-container *ngIf="running; else notRunning">
        <button mat-button (click)="stopAndStart()">
          Stop and Start
        </button>
        <button mat-button (click)="stopAndPause()">
          Stop and Pause
        </button>
        <button mat-button (click)="dropAndPause()">
          Drop and Pause
        </button>
      </ng-container>
      <ng-template #notRunning>
        <button mat-button (click)="start()">
          Start
        </button>
      </ng-template>
    </mat-card-actions>
  </mat-card>
  <result-table [resultEvents$]="resultEventsSubject.asObservable()"></result-table>
</div>
`
})
export class TrainerComponent implements OnDestroy {
  duration: Duration = zeroDuration;
  intervalRef: any = undefined;
  state: StopWatchState = StopWatchState.NotStarted;
  input: InputItem | undefined = undefined;
  modeId: Observable<number>;
  resultEventsSubject = new Subject<void>();

  constructor(private readonly trainerService: TrainerService,
	      activatedRoute: ActivatedRoute) {
    this.modeId = activatedRoute.params.pipe(map(p => p.modeId));
  }

  get running() {
    return this.state == StopWatchState.Running;
  }

  dropAndPause() {
    this.stopTimer();
    this.state = StopWatchState.Paused;
    this.modeId.subscribe(modeId => {
      this.trainerService.dropInput(modeId, this.input!).subscribe(r => {});
    });
  }

  start() {
    this.modeId.subscribe(modeId => {
      this.trainerService.nextInput(modeId).subscribe(input => this.startFor(input));
    });
  }

  startFor(input: InputItem) {
    this.input = input;
    this.state = StopWatchState.Running;
    const start = now();
    this.intervalRef = setInterval(() => {
      this.duration = start.durationUntil(now());
    });
  }

  stopAnd(onSuccess: () => void) {
    this.stopTimer();
    this.state = StopWatchState.Paused;
    this.modeId.subscribe(modeId => {
      this.trainerService.stop(modeId, this.input!, this.duration!).subscribe(r => {
	this.resultEventsSubject.next();
	onSuccess();
      });
    });
  }

  stopAndPause() {
    this.stopAnd(() => {});
  }

  stopAndStart() {
    this.stopAnd(() => this.start());
  }

  stopTimer() {
    clearInterval(this.intervalRef);
  }

  ngOnDestroy() {
    this.stopTimer();
  }

}
