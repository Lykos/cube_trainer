import { Duration } from '@utils/duration';
import { StopwatchStore } from '../stopwatch.store';
import { HostListener, Component, OnInit, OnDestroy, Input } from '@angular/core';
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
  hasStopAndStart?: boolean;

  duration$: Observable<Duration> | undefined = undefined;
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

  onStart() {
    this.checkedStopwatchStore.start();
  }

  onStopAndPause() {
    this.checkedStopwatchStore.stopAndPause();
  }

  onStopAndStart() {
    this.checkedStopwatchStore.stopAndStart();
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
        } else if (!this.loading) {
          this.onStart();
        }
    }
  }
}
