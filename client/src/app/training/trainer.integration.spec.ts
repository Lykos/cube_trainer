import { By } from '@angular/platform-browser';
import { Router } from '@angular/router';
import { ActivatedRoute } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { TrainerComponent } from './trainer/trainer.component';
import { some } from '@utils/optional';
import { TrainerInputComponent } from '@training/trainer-input/trainer-input.component';
import { TrainerStopwatchComponent } from '@training/trainer-stopwatch/trainer-stopwatch.component';
import { StopwatchComponent } from '@training/stopwatch/stopwatch.component';
import { HintComponent } from '@training/hint/hint.component';
import { ResultsTableComponent } from '@training/results-table/results-table.component';
import { DurationPipe } from '@shared/duration.pipe';
import { StoreModule } from '@ngrx/store';
import { of } from 'rxjs';
import { BackendActionLoadErrorComponent } from '@shared/backend-action-load-error/backend-action-load-error.component';
import { TrainingCase } from './training-case.model';
import { TrainingSession } from './training-session.model';
import { TrainingSessionType } from './training-session-type.model';
import { ShowInputMode } from './show-input-mode.model';
import { GeneratorType } from './generator-type.model';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { HttpVerb } from '@core/http-verb';
import { trainingSessionsReducer } from '@store/training-sessions.reducer';
import { trainerReducer } from '@store/trainer.reducer';
import { overrideSelectedTrainingSessionIdForTesting } from '@store/router.selectors';
import { EffectsModule } from '@ngrx/effects';
import { TrainingSessionsEffects } from '@effects/training-sessions.effects';
import { TrainerEffects } from '@effects/trainer.effects';

const trainingSessionType: TrainingSessionType = {
  key: 'test session type key',
  name: 'test session type name',
  showInputModes: [ShowInputMode.Name, ShowInputMode.Picture],
  generatorType: GeneratorType.Case,
  hasGoalBadness: true,
  hasBoundedInputs: true,
  hasMemoTime: false,
  buffers: [],
  statsTypes: [],
  algSets: [],
}

const item: TrainingCase = {
  caseKey: 'test case key',
  caseName: 'test case name',
  alg: 'solve it',
};

const trainingSessionId = 56;

const trainingSession: TrainingSession = {
  id: trainingSessionId,
  name: 'test session',
  trainingCases: [item],
  numResults: 0,
  known: false,
  showInputMode: ShowInputMode.Name,
  goalBadness: 2,
  trainingSessionType
};

fdescribe('TrainerComponent', () => {
  let matDialog: any;
  let matSnackBar: any;
  let httpMock: HttpTestingController;

  beforeEach(async () => {
    overrideSelectedTrainingSessionIdForTesting.value = some(trainingSessionId);
    matDialog = jasmine.createSpyObj('MatDialog', ['open']);
    matSnackBar = jasmine.createSpyObj('MatDialog', ['open']);
    let router = jasmine.createSpyObj('Router', ['navigate']);

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
        HttpClientTestingModule,
        MatProgressSpinnerModule,
        MatTooltipModule,
        StoreModule.forRoot(
          {
            trainingSessions: trainingSessionsReducer,
            trainer: trainerReducer,
          },
        ),
        EffectsModule.forRoot([TrainingSessionsEffects, TrainerEffects]),
      ],
      providers: [
        { provide: ActivatedRoute, useValue: { params: of({ trainingSessionId: 1 }) } },
        { provide: MatDialog, useValue: matDialog },
        { provide: MatSnackBar, useValue: matSnackBar },
        { provide: Router, useValue: router },
      ],
    }).compileComponents();

    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    overrideSelectedTrainingSessionIdForTesting.value = undefined;
  });

  it('should fetch the data and have working start and stop', fakeAsync(() => {
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    {
      const req = httpMock.expectOne('/api/training_sessions/56');
      expect(req.request.method).toEqual(HttpVerb.Get);
      req.flush(trainingSession);
    }
    {
      const req = httpMock.expectOne({url: '/api/training_sessions/56/results', method: HttpVerb.Get });
      req.flush([]);
    }
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    const debug = fixture.debugElement;
    expect(compiled.querySelector('#trainer-input')?.textContent).toContain('test case name');
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('0');
    console.log('clicking start');
    console.log(compiled);
    console.log(debug);
    debug.query(By.css('#stopwatch-start')).triggerEventHandler('click', null);
    fixture.detectChanges();

    tick(100);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('0.1');
    expect(compiled.querySelector('.alg')?.textContent).toBeFalsy();
    debug.query(By.css('#trainer-hint')).triggerEventHandler('click', null);
    fixture.detectChanges();
    expect(compiled.querySelector('.alg')?.textContent).toContain('solve it');

    tick(1100);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('1.2');
    console.log('clicking start stop and start');
    debug.query(By.css('#stopwatch-stop-and-start')).triggerEventHandler('click', null);
    fixture.detectChanges();
    {
      const req = httpMock.expectOne({ url: '/api/training_sessions/56/results', method: HttpVerb.Post });
      expect(req.request.body).toEqual({ result: { case_key: 'test case key', case_name: 'test case name', num_hints: 1, time_s: 1.2, success: true } });
      req.flush({});
    }

    tick(1300);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('1.3');
    console.log('clicking start stop and pause');
    debug.query(By.css('#stopwatch-stop-and-pause')).triggerEventHandler('click', null);
    fixture.detectChanges();
    {
      const req = httpMock.expectOne({ url: '/api/training_sessions/56/results', method: HttpVerb.Post });
      expect(req.request.body).toEqual({ result: { case_key: 'test case key', case_name: 'test case name', num_hints: 0, time_s: 1.3, success: true } });
      req.flush({});
    }
  }));
});
