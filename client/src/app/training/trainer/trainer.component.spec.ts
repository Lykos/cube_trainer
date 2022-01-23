import { ActivatedRoute } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { TestBed } from '@angular/core/testing';
import { TrainerComponent } from './trainer.component';
import { TrainerInputComponent } from '@training/trainer-input/trainer-input.component';
import { TrainerStopwatchComponent } from '@training/trainer-stopwatch/trainer-stopwatch.component';
import { StopwatchComponent } from '@training/stopwatch/stopwatch.component';
import { HintComponent } from '@training/hint/hint.component';
import { ResultsTableComponent } from '@training/results-table/results-table.component';
import { DurationPipe } from '@shared/duration.pipe';
import { TrainerService } from '../trainer.service';
import { provideMockStore, MockStore } from '@ngrx/store/testing';
import { of } from 'rxjs';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { selectNextCase } from '@store/trainer.selectors';
import { none, some } from '@utils/optional';
import { BackendActionLoadErrorComponent } from '@shared/backend-action-load-error/backend-action-load-error.component';
import { ScrambleOrSample } from '../scramble-or-sample.model';
import { TrainingCase } from '../training-case.model';
import { TrainingSession } from '../training-session.model';
import { ShowInputMode } from '../show-input-mode.model';
import { GeneratorType } from '../generator-type.model';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

function exampleError(message: string) {
  return {
    context: {
      subject: 'test',
      action: 'running',
    },
    message,
    fieldErrors: [],
  };
}

const item: TrainingCase = {
  casee: {
    key: 'test case key',
    name: 'test case name',
    rawName: 'test case name',
  },
};

const trainingSession: TrainingSession = {
  id: 1,
  name: 'test session',
  trainingCases: [item],
  numResults: 0,
  known: false,
  showInputMode: ShowInputMode.Name,
  generatorType: GeneratorType.Case,
  stats: [],
};

const scrambleOrSample: ScrambleOrSample = {
  tag: 'sample',
  sample: {
    item,
    samplerName: 'test sampler',
  },
};

describe('TrainerComponent', () => {
  let trainerService, matDialog: any;
  let store: MockStore;

  beforeEach(async () => {
    trainerService = jasmine.createSpyObj('TrainerService', ['randomCase', 'randomScramble']);
    matDialog = jasmine.createSpyObj('MatDialog', ['open']);

    await TestBed.configureTestingModule({
      declarations: [
        TrainerComponent,
        TrainerInputComponent,
        TrainerStopwatchComponent,
        StopwatchComponent,
        HintComponent,
        ResultsTableComponent,
        DurationPipe,
        BackendActionLoadErrorComponent,
      ],
      imports: [
        MatProgressSpinnerModule,
      ],
      providers: [
        { provide: ActivatedRoute, useValue: { params: of({ trainingSessionId: 1 }) } },
        { provide: TrainerService, useValue: trainerService },
        { provide: MatDialog, useValue: matDialog },
        provideMockStore({}),
      ],
    }).compileComponents();

    store = TestBed.inject(MockStore);
  });

  it('should create the trainer', () => {
    const fixture = TestBed.createComponent(TrainerComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should initially be loading', () => {
    store.overrideSelector(selectSelectedTrainingSession, none);
    store.overrideSelector(selectInitialLoadLoading, true);
    store.overrideSelector(selectInitialLoadError, none);
    store.overrideSelector(selectNextCase, none);
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#initial-load-loading')).toBeTruthy();
  });

  it('should display an error if initial loading failed', () => {
    store.overrideSelector(selectSelectedTrainingSession, none);
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, some(exampleError('stuff went wrong')));
    store.overrideSelector(selectNextCase, none);
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#initial-load-error')?.textContent).toContain('stuff went wrong');
  });

  it('should display the input and stopwatch if a case was loaded', () => {
    store.overrideSelector(selectSelectedTrainingSession, some(trainingSession));
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, none);
    store.overrideSelector(selectNextCase, some(scrambleOrSample));
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#trainer-input')?.textContent).toContain('test case name');
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('0');
  });
});
