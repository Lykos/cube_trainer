import { Duration } from '../../utils/duration';
import { StopwatchStore } from '../stopwatch.store';
import { HostListener, Component, OnInit, OnDestroy, Input, Output, EventEmitter } from '@angular/core';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-stopwatch',
  templateUrl: './stopwatch.component.html',
  styleUrls: ['./stopwatch.component.css']
})
export class StopwatchComponent implements OnDestroy, OnInit {
  @Input()
  stopwatchStore?: StopwatchStore;

  @Input()
  memoTime?: Duration;

  @Input()
  maxHints?: number;

  @Input()
  hasStopAndStart?: boolean;

  @Output()
  private numHints: EventEmitter<number> = new EventEmitter();

  duration$: Observable<Duration> | undefined = undefined;
  private numHints_ = 0;
  running = false;
  loading = true;

  private runningSubscription: any = undefined;
  private loadingSubscription: any = undefined;

  get checkedStopwatchStore(): StopwatchStore {
    const stopwatchStore = this.stopwatchStore;
    if (!stopwatchStore) {
      throw new Error('stopwatchStore has to be defined');
    }
    return stopwatchStore;
  }

  ngOnInit() {
    this.duration$ = this.checkedStopwatchStore.duration$;
    this.runningSubscription = this.checkedStopwatchStore.running$.subscribe(r => { this.running = r; });
    this.loadingSubscription = this.checkedStopwatchStore.loading$.subscribe(r => { this.loading = r; });
  }

  ngOnDestroy() {
    this.runningSubscription?.unsubscribe();
    this.loadingSubscription?.unsubscribe();
  }

  isPostMemoTime(duration: Duration) {
    return this.memoTime && duration.greaterThan(this.memoTime);
  }

  get hintsAvailable() {
    return this.maxHints && this.numHints_ < this.maxHints;
  }

  onStart() {
    this.checkedStopwatchStore.start();
    this.numHints_ = 0;
    this.numHints.emit(0);
  }

  onStopAndPause() {
    this.checkedStopwatchStore.stopAndPause();
  }

  onStopAndStart() {
    this.checkedStopwatchStore.stopAndStart();
  }

  onHint() {
    ++this.numHints_;
    this.numHints.emit(this.numHints_);
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    switch (event.key) {
      case 'h':
        this.onHint();
        return;
      case 'Enter':
      case ' ':
        if (this.running) {
          if (this.hasStopAndStart) {
            this.onStopAndStart();
          } else {
            this.onStopAndPause();
          }
        } else if (!this.loading) {
          this.onStart();
        }
    }
  }
}
