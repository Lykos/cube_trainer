import { now } from '../../utils/instant';
import { Duration } from '../../utils/duration';
import { Component, OnDestroy } from '@angular/core';
import Rails from '@rails/ujs';

enum TimerState {
  NotStarted,
  Running,
  Paused
};

interface InputItem {
  readonly id: number;
  readonly inputRepresentation: String;
};

@Component({
  selector: 'timer',
  template: `
<div class="container">
  <section class="error" *ngIf="error"> {{error}} </section>
  <section *ngIf="input" class="timer-input-label">
    {{input.inputRepresentation}}
  </section>
  <section class="timer-counter-label">
    <div *ngIf="duration; else elseBlock"> {{duration}} </div>
    <ng-template #elseBlock> Press Start </ng-template>
  </section>
  <section class="timer-button-container">
    <ng-container *ngIf="running(); else notRunning">
      <button class="timer-button" (click)="stopAndStart()">
        Stop and Start
      </button>
      <button class="timer-button" (click)="stopAndPause()">
        Stop and Pause
      </button>
      <button class="timer-button" (click)="reset()">
        Reset
      </button>
    </ng-container>
    <ng-template #notRunning>
      <button class="timer-button" (click)="start()">
        Start
      </button>
    </ng-template>
  </section>
</div>
`,
  styles: [`
container {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: monospace;
}

.timer-input-label{
  display: flex;
  align-items: center;
  font-size: 10em;
  margin-bottom: 0.5em;
  min-height: 350px;
}

.timer-counter-label{
  display: flex;
  align-items: center;
  font-size: 10em;
  margin-bottom: 0.5em;
  min-height: 350px;
}

.timer-button-container{
  display: flex;
}

.timer-button{
      border: 1px solid #ccc;
      border-radius: 5px;
      background: #fff;
      font-size: 2em;
      padding: 10px;
      margin: 5px 10px;
      min-width: 150px;
}
`]
})
export class TimerComponent implements OnDestroy {
  error: String | undefined = undefined;
  duration: Duration | undefined = undefined;
  intervalRef: any = undefined;
  state: TimerState = TimerState.NotStarted;
  input: InputItem | undefined = undefined;

  running() {
    return this.state == TimerState.Running;
  }

  start() {
    Rails.ajax({
      type: 'POST', 
      url: '/timer/next_input',
      data: '',
      success: (response: any) => { this.startFor(response); },
      error: (response: any) => { this.onError(response); }
    });
  }

  startFor(input: InputItem) {
    console.log(input);
    this.input = input;
    this.state = TimerState.Running;
    const start = now();
    this.intervalRef = setInterval(() => {
      this.duration = start.durationUntil(now());
    });
  }

  stopAnd(onSuccess: () => void) {
    this.stopTimer();
    this.state = TimerState.Paused;
    Rails.ajax({
      type: 'POST', 
      url: '/timer/stop',
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

  onError(error: String) {
    this.stopTimer();
    this.error = error;
  }

  ngOnDestroy() {
    this.stopTimer();
  }

}
