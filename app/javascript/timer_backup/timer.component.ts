import { Component } from '@angular/core';

@Component({
  selector: 'timer',
  template: `<h1>Hello {{name}}</h1>`
})
export class TimerComponent {
  name = 'Angular!';
}

/*
import { now } from '../utils/instant';
import { Duration, zeroDuration } from '../utils/duration';
import { Component, OnDestroy } from '@angular/core';

@Component({
  selector: 'timer',
  template: `<h1>Hello {{name}}</h1>`,
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
*/
