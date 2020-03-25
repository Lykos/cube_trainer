const UPDATE_INTERVAL = 10;

class Timer {
  timerElement: HTMLElement;
  start: Date;
  timerToken: number;

  constructor(timerElement: HTMLElement) {
    this.timerElement = timerElement;
  }

  start() {
    start = Date.new
    timerToken = setInterval(() -> this.update(), UPDATE_INTERVAL);
  }

  update() {
    timerElement.innerHTML = Date.now - start;
  }

  stop() {
    clearInterval(timerToken);
  }
}
