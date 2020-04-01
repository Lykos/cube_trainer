import { now } from '../../../utils/instant';
import { Duration } from '../../../utils/duration';
import { InputItem } from './trainer_input.component';
import { TrainerService } from './trainer.service';
import { Component, OnDestroy, Input } from '@angular/core';
// @ts-ignore
import Rails from '@rails/ujs';

enum StopWatchState {
  NotStarted,
  Running,
  Paused
};

@Component({
  selector: 'trainer',
  template: `
<div class="container">
  <section class="error" *ngIf="error"> {{error}} </section>
  <trainer-input [input]=input></trainer-input>
  <mat-card>
    <mat-card-title>Time</mat-card-title>
    <mat-card-content>
      <div *ngIf="duration; else elseBlock"> {{duration}} </div>
      <ng-template #elseBlock> Press Start </ng-template>
    </mat-card-content>
    <mat-card-actions>
      <ng-container *ngIf="running(); else notRunning">
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
</div>
`
})
export class TrainerComponent implements OnDestroy {
  error: string | undefined = undefined;
  duration: Duration | undefined = undefined;
  intervalRef: any = undefined;
  state: StopWatchState = StopWatchState.NotStarted;
  input: InputItem | undefined = undefined;

  @Input()
  public modeId: number | undefined = undefined;

  constructor(private readonly trainerService: TrainerService) {}

  running() {
    return this.state == StopWatchState.Running;
  }

  dropAndPause() {
    this.stopTimer();
    this.state = StopWatchState.Paused;
    Rails.ajax({
      type: 'POST', 
      url: `/timer/${this.modeId}/drop_input`,
      data: `id=${this.input!.id}`,
      success: (response: any) => {},
      error: (response: any) => { this.onError(response); }
    });
  }

  start() {
    Rails.ajax({
      type: 'POST', 
      url: `/timer/${this.modeId}/next_input`,
      data: '',
      success: (response: any) => { this.startFor(response); },
      error: (response: any) => { this.onError(response); }
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
    Rails.ajax({
      type: 'POST', 
      url: `/timer/${this.modeId}/stop`,
      // TODO find a better way to encode this data.
      data: `id=${this.input!.id}&time_s=${this.duration!.toSeconds()}`,
      success: (response: any) => { onSuccess(); },
      error: (response: any) => { this.onError(response); }
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

  onError(error: string) {
    this.stopTimer();
    this.error = error;
  }

  ngOnDestroy() {
    this.stopTimer();
  }

}
