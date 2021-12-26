import { now } from '../../utils/instant';
import { Duration, zeroDuration } from '../../utils/duration';
import { Case } from '../case.model';
import { Mode } from '../../modes/mode.model';
import { TrainerService } from '../trainer.service';
import { ResultsService } from '../results.service';
import { HostListener, Component, OnDestroy, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { PartialResult } from '../partial-result.model';
import { interval, timer } from 'rxjs';

enum StopWatchState {
  NotStarted,
  Running,
  Paused
};

@Component({
  selector: 'cube-trainer-stopwatch',
  templateUrl: './stopwatch.component.html',
  styleUrls: ['./stopwatch.component.css']
})
export class StopwatchComponent implements OnDestroy, OnInit {
  @Input()
  mode!: Mode;

  @Output()
  private casee: EventEmitter<Case> = new EventEmitter();

  @Output()
  private resultSaved: EventEmitter<void> = new EventEmitter();

  @Output()
  private numHints: EventEmitter<number> = new EventEmitter();

  private casee_: Case | undefined = undefined;
  private numHints_ = 0;
  private maxHints = 0;
  duration: Duration = zeroDuration;
  private intervalSubscription: any = undefined;
  private memoTimeSubscription: any = undefined;
  private state: StopWatchState = StopWatchState.NotStarted;
  private goAudio: HTMLAudioElement | undefined = undefined;

  constructor(private readonly trainerService: TrainerService,
              private readonly resultsService: ResultsService) {}

  get hintsAvailable() {
    return this.numHints_ < this.maxHints;
  }

  get running() {
    return this.state == StopWatchState.Running;
  }

  get notStarted() {
    return this.state == StopWatchState.NotStarted;
  }

  get partialResult(): PartialResult {
    return {
      numHints: this.numHints_,
      duration: this.duration!,
      success: true,
    }
  }

  get hasSetup() {
    return this.mode.modeType.hasSetup;
  }

  get memoTime() {
    return this.mode.memoTime;
  }

  get isPostMemoTime() {
    return this.running && this.memoTime && this.duration.greaterThan(this.memoTime);
  }

  onStart() {
    if (this.hasSetup) {
      // TODO: Handle the (unlikely) situation that the input hasn't been received yet.
      this.startFor(this.casee_!);
    } else {
      this.trainerService.nextCaseWithCache(this.mode.id).subscribe(casee => this.startFor(casee));
    }
  }

  startFor(casee: Case) {
    this.numHints_ = 0;
    this.numHints.emit(this.numHints_);
    this.maxHints = casee.alg ? 1 : 0;
    this.casee_ = casee;
    // TODO: Make the emit location depending on hasSetup nicer.
    if (!this.hasSetup) {
      this.casee.emit(casee);
    }
    this.state = StopWatchState.Running;
    const start = now();
    if (this.intervalSubscription) {
      throw 'Timer started when it was already running.';
    }
    this.intervalSubscription = interval(10).subscribe(() => {
      this.duration = start.durationUntil(now());
    });
    if (this.memoTime) {
      this.memoTimeSubscription = timer(this.memoTime.toMillis()).subscribe(() => {
        this.goAudio!.play();
      });
    }
  }

  stopAnd(onSuccess: () => void) {
    this.stopInterval();
    this.state = StopWatchState.Paused;
    this.resultsService.create(this.mode.id, this.casee_!, this.partialResult).subscribe(() => {
      this.resultSaved.emit();
      this.maybePrefetchCaseAnd(onSuccess);
    });
  }

  onStopAndPause() {
    this.stopAnd(() => {});
  }

  onStopAndStart() {
    this.stopAnd(() => this.onStart());
  }

  onHint() {
    if (this.hintsAvailable) {
      ++this.numHints_;
      this.numHints.emit(this.numHints_);
    }
  }

  stopInterval() {
    if (!this.intervalSubscription) {
      return;
    }
    this.intervalSubscription.unsubscribe();
    this.intervalSubscription = undefined;
    if (this.memoTimeSubscription) {
      this.memoTimeSubscription.unsubscribe();
      this.memoTimeSubscription = undefined;
    }
  }

  ngOnDestroy() {
    this.stopInterval();
  }

  maybePrefetchCaseAnd(onSuccess: () => void) {
    if (this.hasSetup) {
      this.trainerService.nextCaseWithCache(this.mode.id).subscribe(casee => {
        this.casee_ = casee;
        // TODO: Make the emit location depending on hasSetup nicer.
        this.casee.emit(casee);
        onSuccess();
      });
    } else {
      onSuccess();
    }
  }

  ngOnInit() {
    this.maybePrefetchCaseAnd(() => {});
    if (this.memoTime) {
      this.goAudio = new Audio('../../assets/audio/go.wav');
    }
  }

  @HostListener('window:keydown', ['$event'])
  onKeyDown(event: KeyboardEvent) {
    if (event.key === 'h') {
      this.onHint();
      return;
    }
    if (this.running) {
      if (this.hasSetup) {
        this.onStopAndPause();
      } else {
        this.onStopAndStart();
      }
    } else if (this.notStarted) {
      this.onStart();
    }
  }
}
