import { now } from '../../utils/instant';
import { Duration, zeroDuration } from '../../utils/duration';
import { Component, OnDestroy } from '@angular/core';

@Component({
  selector: 'timer',
  template: `
<div class="container">
  <section class="timer-counter-label">
    <div *ngIf="duration; else elseBlock"> {{duration}} </div>
    <ng-template #elseBlock> Press Start </ng-template>
  </section>
  <section class="timer-button-container">
    <button class="timer-button" (click)="startTimer()">
      {{startText}}
    </button>
    <button class="timer-button" (click)="clearTimer()">Clear</button>
  </section>
</div>
`
  styles: [`
container {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: monospace;
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
  name = 'Angular!';
  duration: Duration | undefined = undefined;
  timerRef: any = undefined;
  running: boolean = false;
  startText = 'Start';

  startTimer() {
    this.running = !this.running;
    if (this.running) {
      this.startText = 'Stop';
      const start = now().minus(this.duration || zeroDuration);
      this.timerRef = setInterval(() => {
        this.duration = start.durationUntil(now());
      });
    } else {
      this.startText = 'Resume';
      clearInterval(this.timerRef);
    }
  }

  clearTimer() {
    this.running = false;
    this.startText = 'Start';
    this.duration = undefined;
    clearInterval(this.timerRef);
  }

  ngOnDestroy() {
    clearInterval(this.timerRef);
  }

}
