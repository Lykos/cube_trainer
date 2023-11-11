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

  @Input()
  hasStopAndPause?: boolean;

  @Input()
  algOverrideActive?: boolean;
  
  @Output()
  readonly startt = new EventEmitter<void>();

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
    this.startt.emit();
  }

  onStopAndPause() {
    this.stopAndPause.emit();
  }

  onStopAndStart() {
    this.stopAndStart.emit();
  }

  get startTooltip() {
    return "Start the stopwatch. You can also press enter or space for this."
  }

  get stopTooltip() {
    return "Stop the stopwatch. You can also press enter or space for this."
  }
  
  get stopAndPauseTooltip() {
    return "Stop the stopwatch and then pause. You can also press p for this."
  }
  
  get stopAndStartTooltip() {
    return "Stop the stopwatch and then immediately start the next algorithm without pause. You can also press enter or space for this. This is the recommended way to use cube trainer."
  }
  
  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (this.algOverrideActive) {
      return;
    }
    switch (event.key) {
      case 'p':
	if (this.running && this.hasStopAndStart) {
	  this.onStopAndPause();
	}
	return;
      case 'Enter':
      case ' ':
        if (this.running) {
          if (this.hasStopAndStart) {
            this.onStopAndStart();
          } else if (this.hasStopAndPause) {
            this.onStopAndPause();
          }
        } else if (this.startReady) {
          this.onStart();
        }
    }
  }
}
