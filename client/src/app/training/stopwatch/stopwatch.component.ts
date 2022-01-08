import { Duration, zeroDuration } from '@utils/duration';
import { HostListener, Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'cube-trainer-stopwatch',
  templateUrl: './stopwatch.component.html',
  styleUrls: ['./stopwatch.component.css']
})
export class StopwatchComponent {
  @Input()
  duration?: Duration | null;

  @Input()
  running?: boolean;

  @Input()
  startReady?: boolean;

  @Input()
  memoTime?: Duration;

  @Input()
  hasStopAndStart?: boolean;

  @Output()
  readonly start = new EventEmitter<void>();

  @Output()
  readonly stopAndPause = new EventEmitter<void>();

  @Output()
  readonly stopAndStart = new EventEmitter<void>();

  get displayedDuration() {
    return this.duration || zeroDuration;
  }

  get isPostMemoTime() {
    return this.memoTime && this.duration && this.duration.greaterThan(this.memoTime);
  }

  onStart() {
    this.start.emit();
  }

  onStopAndPause() {
    this.stopAndPause.emit();
  }

  onStopAndStart() {
    this.stopAndStart.emit();
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    switch (event.key) {
      case 'Enter':
      case ' ':
        if (this.running) {
          if (this.hasStopAndStart) {
            this.onStopAndStart();
          } else {
            this.onStopAndPause();
          }
        } else if (this.startReady) {
          this.onStart();
        }
    }
  }
}
