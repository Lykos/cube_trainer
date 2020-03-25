import { Instant, now, infinitePast } from './instant';
import { millis } from './duration';

const updateInterval = millis(10);

export class Timer {
  private startDate: Instant;
  private timerToken: any;

  constructor(private timerElement: HTMLElement) {
    this.timerElement = timerElement;
    this.startDate = infinitePast;
  }

  start() {
    this.startDate = now();
    this.timerToken = setInterval(() => this.update(), updateInterval.toMillis());
  }

  private update() {
    this.timerElement.innerHTML = this.startDate.durationUntil(now()).toString();
  }

  stop() {
    clearInterval(this.timerToken);
  }
}
