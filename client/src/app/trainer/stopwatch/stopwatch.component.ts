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
  stopwatchStore: StopwatchStore;

  @Input()
  memoTime: Duration;

  @Input()
  maxHints: number;

  @Input()
  hasStopAndStart: boolean;

  @Output()
  private numHints: EventEmitter<number> = new EventEmitter();

  duration$: Observable<Duration> | undefined = undefined;
  private numHints_ = 0;
  running = false;
  loading = true;
  notStarted = true;

  private runningSubscription: any = undefined;
  private loadingSubscription: any = undefined;
  private notStartedSubscription: any = undefined;

  ngOnInit() {
    this.duration$ = this.stopwatchStore.duration$;
    this.runningSubscription = this.stopwatchStore?.running$.subscribe(r => { this.running = r; });
    this.loadingSubscription = this.stopwatchStore?.loading$.subscribe(r => { this.loading = r; });
    this.notStartedSubscription = this.stopwatchStore?.notStarted$.subscribe(r => { this.notStarted = r; });
  }

  ngOnDestroy() {
    this.runningSubscription?.unsubscribe();
    this.loadingSubscription?.unsubscribe();
    this.notStartedSubscription?.unsubscribe();
  }

  isPostMemoTime(duration: Duration) {
    return this.memoTime && duration.greaterThan(this.memoTime);
  }

  get hintsAvailable() {
    return this.maxHints && this.numHints_ < this.maxHints;
  }

  onStart() {
    this.stopwatchStore.start();
    this.numHints_ = 0;
  }

  onStopAndPause() {
    this.stopwatchStore.stopAndPause();
  }

  onStopAndStart() {
    this.stopwatchStore.stopAndStart();
  }

  onHint() {
    ++this.numHints_;
    this.numHints.emit(this.numHints_);
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h') {
      this.onHint();
      return;
    }
    if (this.running) {
      if (this.hasStopAndStart) {
        this.onStopAndStart();
      } else {
        this.onStopAndPause();
      }
    } else if (this.notStarted) {
      this.onStart();
    }
  }
}
