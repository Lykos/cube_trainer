import { By } from '@angular/platform-browser';
import { fromDateString, fromUnixMillis } from '@utils/instant';
import { seconds } from '@utils/duration';
import { TestBed } from '@angular/core/testing';
import { TrainerStopwatchComponent } from '@training/trainer-stopwatch/trainer-stopwatch.component';
import { StopwatchComponent } from '@training/stopwatch/stopwatch.component';
import { DurationPipe } from '@shared/duration.pipe';
import { provideMockStore, MockStore } from '@ngrx/store/testing';
import { selectStopwatchState, selectStopwatchRunning, selectNextCaseReady } from '@store/trainer.selectors';
import { notStartedStopwatchState, runningStopwatchState, stoppedStopwatchState } from '@store/trainer.state';
import { TrainingSession } from '../training-session.model';
import { TrainingSessionType } from '../training-session-type.model';
import { ShowInputMode } from '../show-input-mode.model';
import { GeneratorType } from '../generator-type.model';import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

const trainingSessionType: TrainingSessionType = {
  key: 'test session type key',
  name: 'test session type name',
  showInputModes: [ShowInputMode.Scramble],
  generatorType: GeneratorType.Scramble,
  hasGoalBadness: false,
  hasBoundedInputs: false,
  hasMemoTime: true,
  buffers: [],
  statsTypes: [],
  algSets: [],
}

const trainingSession: TrainingSession = {
  id: 1,
  name: 'test session',
  trainingCases: [],
  numResults: 0,
  known: false,
  showInputMode: ShowInputMode.Scramble,
  trainingSessionType,
  memoTimeS: 2,
};

const now = fromDateString('2021-01-01');

describe('TrainerStopwatchComponent', () => {
  let store: MockStore;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [
        TrainerStopwatchComponent,
        StopwatchComponent,
        DurationPipe,
      ],
      imports: [
        MatProgressSpinnerModule,
      ],
      providers: [
        provideMockStore({}),
      ],
    }).compileComponents();

    store = TestBed.inject(MockStore);
    jasmine.clock().install();
    jasmine.clock().mockDate(now.toDate());
  });

  afterEach(() => {
    jasmine.clock().uninstall();
  });

  it('should create the trainer', () => {
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should be empty without a training session', () => {
    store.overrideSelector(selectStopwatchState, notStartedStopwatchState);
    store.overrideSelector(selectStopwatchRunning, false);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.textContent).toEqual('');
  });

  it('should initially be loading', () => {
    store.overrideSelector(selectStopwatchState, notStartedStopwatchState);
    store.overrideSelector(selectStopwatchRunning, false);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#stopwatch-loading')).toBeTruthy();
  });

  it('should display the time and the start button when ready', () => {
    store.overrideSelector(selectStopwatchState, notStartedStopwatchState);
    store.overrideSelector(selectStopwatchRunning, false);
    store.overrideSelector(selectNextCaseReady, true);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.textContent).toContain('0');
    expect(compiled.querySelector('#stopwatch-loading')).toBeFalsy();
    expect(compiled.querySelector('#stopwatch-start')).toBeTruthy();
    expect(compiled.querySelector('#stopwatch-stop-and-start')).toBeFalsy();
    expect(compiled.querySelector('#stopwatch-stop-and-pause')).toBeFalsy();
  });

  it('should display the time and the stop button when running', () => {
    const start = now.minus(seconds(1));
    store.overrideSelector(selectStopwatchState, runningStopwatchState(start.toUnixMillis()));
    store.overrideSelector(selectStopwatchRunning, true);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    jasmine.clock().tick(10);
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.textContent).toContain('1.01');
    expect(compiled.querySelector('#stopwatch-loading')).toBeFalsy();
    expect(compiled.querySelector('#stopwatch-start')).toBeFalsy();
    expect(compiled.querySelector('#stopwatch-stop-and-start')).toBeFalsy();
    expect(compiled.querySelector('#stopwatch-stop-and-pause')).toBeTruthy();
  });

  it('should give a visual cue when the memo time is reached', () => {
    const start = now;
    store.overrideSelector(selectStopwatchState, runningStopwatchState(start.toUnixMillis()));
    store.overrideSelector(selectStopwatchRunning, true);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    jasmine.clock().tick(2000);
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('.post-memo-time')).toBeFalsy();

    jasmine.clock().tick(10);
    fixture.detectChanges();
    expect(compiled.querySelector('.post-memo-time')).toBeTruthy();
  });

  it('should dispatch the start event when started', () => {
    store.overrideSelector(selectStopwatchState, notStartedStopwatchState);
    store.overrideSelector(selectStopwatchRunning, false);
    store.overrideSelector(selectNextCaseReady, true);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    const debug = fixture.debugElement;
    let action: any;
    store.scannedActions$.subscribe(a => action = a);

    debug.query(By.css('#stopwatch-start'))?.triggerEventHandler('click', null);

    expect(action?.type).toEqual('[Trainer] start stopwatch');
    expect(action?.trainingSessionId).toEqual(trainingSession.id);
    expect(fromUnixMillis(action?.startUnixMillis)).toEqual(now);
  });

  it('should dispatch the stop and pause event when stopped and paused', () => {
    const start = now.minus(seconds(1));
    store.overrideSelector(selectStopwatchState, runningStopwatchState(start.toUnixMillis()));
    store.overrideSelector(selectStopwatchRunning, true);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;
    fixture.detectChanges();
    const debug = fixture.debugElement;
    let action: any;
    store.scannedActions$.subscribe(a => action = a);

    debug.query(By.css('#stopwatch-stop-and-pause'))?.triggerEventHandler('click', null);

    expect(action?.type).toEqual('[Trainer] stop stopwatch and do not start again once the next case is loaded');
    expect(action?.trainingSessionId).toEqual(trainingSession.id);
    expect(fromUnixMillis(action?.stopUnixMillis)).toEqual(now);
  });

  it('should keep displaying the time when stopped and paused', () => {
    store.overrideSelector(selectStopwatchState, stoppedStopwatchState(1590));
    store.overrideSelector(selectStopwatchRunning, true);
    store.overrideSelector(selectNextCaseReady, false);
    const fixture = TestBed.createComponent(TrainerStopwatchComponent);
    fixture.componentInstance.trainingSession = trainingSession;

    fixture.detectChanges();
    jasmine.clock().tick(10);
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.textContent).toContain('1.59');
  });
});
