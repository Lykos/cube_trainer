import { By } from '@angular/platform-browser';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { Router } from '@angular/router';
import { ActivatedRoute } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { TrainingSessionComponent } from '@training/training-session/training-session.component';
import { TrainerComponent } from '@training/trainer/trainer.component';
import { some } from '@utils/optional';
import { TrainerInputComponent } from '@training/trainer-input/trainer-input.component';
import { TrainerStopwatchComponent } from '@training/trainer-stopwatch/trainer-stopwatch.component';
import { StopwatchComponent } from '@training/stopwatch/stopwatch.component';
import { StopwatchDialogComponent } from '@training/stopwatch-dialog/stopwatch-dialog.component';
import { HintComponent } from '@training/hint/hint.component';
import { ResultsTableComponent } from '@training/results-table/results-table.component';
import { DurationPipe } from '@shared/duration.pipe';
import { FluidInstantPipe } from '@shared/fluid-instant.pipe';
import { InstantPipe } from '@shared/instant.pipe';
import { StoreModule } from '@ngrx/store';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { BackendActionLoadErrorComponent } from '@shared/backend-action-load-error/backend-action-load-error.component';
import { GithubErrorNoteComponent } from '@shared/github-error-note/github-error-note.component';
import { TrainingCase } from '@training/training-case.model';
import { TrainingSession } from '@training/training-session.model';
import { ShowInputMode } from '@training/show-input-mode.model';
import { GeneratorType } from '@training/generator-type.model';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { HttpVerb } from '@core/http-verb';
import { trainingSessionsReducer } from '@store/training-sessions.reducer';
import { colorSchemeReducer } from '@store/color-scheme.reducer';
import { trainerReducer } from '@store/trainer.reducer';
import { overrideSelectedTrainingSessionIdForTesting } from '@store/router.selectors';
import { EffectsModule } from '@ngrx/effects';
import { TrainingSessionsEffects } from '@effects/training-sessions.effects';
import { StatsTableComponent } from '@training/stats-table/stats-table.component';
import { TrainerEffects } from '@effects/trainer.effects';
import { routerReducer } from '@ngrx/router-store';
import { BreakpointObserver, Breakpoints, BreakpointState } from '@angular/cdk/layout';

const item: TrainingCase = {
  casee: {
    key: 'test case key',
    name: 'test case name',
    rawName: 'raw test case name',
  },
  alg: 'solve it',
  algSource: { tag: 'original' },
};

const trainingSessionId = 56;

const trainingSession: TrainingSession = {
  id: trainingSessionId,
  name: 'test session',
  trainingCases: [item],
  known: false,
  showInputMode: ShowInputMode.Name,
  goalBadness: 2,
  generatorType: GeneratorType.Case,
  stats: [],
};

const initialBreakpointState: BreakpointState = {matches: false, breakpoints: {}};

class FakeBreakpointObserver {
  private state: BehaviorSubject<BreakpointState> = new BehaviorSubject(initialBreakpointState);

  setSmall(isSmall: boolean) {
    this.state.next({ matches: isSmall, breakpoints: {} });
  }

  observe(breakpoints: readonly string[]): Observable<BreakpointState> {
    if (breakpoints.length != 2 || breakpoints[0] !== Breakpoints.XSmall || breakpoints[1] != Breakpoints.Small) {
      return of();
    }
    return this.state.asObservable();
  }
}

describe('TrainingSessionComponentIntegration', () => {
  let matDialog: any;
  let matSnackBar: any;
  let httpMock: HttpTestingController;

  beforeEach(async () => {
    overrideSelectedTrainingSessionIdForTesting.value = some(trainingSessionId);
    matDialog = jasmine.createSpyObj('MatDialog', ['open']);
    matSnackBar = jasmine.createSpyObj('MatDialog', ['open']);
    let router = jasmine.createSpyObj('Router', ['navigate']);

    await TestBed.configureTestingModule({
    imports: [
        NoopAnimationsModule,
        HttpClientTestingModule,
        MatProgressSpinnerModule,
        MatTooltipModule,
        MatCheckboxModule,
        MatTableModule,
        MatPaginatorModule,
        StoreModule.forRoot({
            trainingSessions: trainingSessionsReducer,
            trainer: trainerReducer,
            router: routerReducer,
            colorScheme: colorSchemeReducer,
        }),
        EffectsModule.forRoot([TrainingSessionsEffects, TrainerEffects]),
        TrainingSessionComponent,
        TrainerComponent,
        TrainerInputComponent,
        TrainerStopwatchComponent,
        StopwatchComponent,
        HintComponent,
        ResultsTableComponent,
        DurationPipe,
        FluidInstantPipe,
        StatsTableComponent,
        InstantPipe,
        BackendActionLoadErrorComponent,
        GithubErrorNoteComponent,
        StopwatchDialogComponent,
    ],
    providers: [
        { provide: ActivatedRoute, useValue: { params: of({ trainingSessionId: 1 }) } },
        { provide: MatDialog, useValue: matDialog },
        { provide: MatSnackBar, useValue: matSnackBar },
        { provide: Router, useValue: router },
        { provide: BreakpointObserver, useClass: FakeBreakpointObserver },
    ],
}).compileComponents();

    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    overrideSelectedTrainingSessionIdForTesting.value = undefined;
  });

  it('should fetch the data and have working start and stop', fakeAsync(() => {
    const fixture = TestBed.createComponent(TrainingSessionComponent);
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
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('0');
    debug.query(By.css('#stopwatch-start')).triggerEventHandler('click', null);
    fixture.detectChanges();

    expect(compiled.querySelector('#trainer-input')?.textContent).toContain('test case name');
    tick(100);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('0.1');
    expect(compiled.querySelector('.alg')?.textContent).toContain('\xa0');
    debug.query(By.css('#trainer-hint')).triggerEventHandler('click', null);
    fixture.detectChanges();
    expect(compiled.querySelector('.alg')?.textContent).toContain('solve it');

    tick(1100);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('1.2');
    debug.query(By.css('#stopwatch-stop-and-start')).triggerEventHandler('click', null);
    fixture.detectChanges();
    {
      const req = httpMock.expectOne({ url: '/api/training_sessions/56/results', method: HttpVerb.Post });
      expect(req.request.body).toEqual({ result: { case_key: 'test case key', num_hints: 1, time_s: 1.2, success: true } });
      req.flush({ id: 1, created_at: '2022-01-01 09:22', casee: { key: 'test case key', name: 'test case name', raw_name: 'raw test case name' }, num_hints: 1, time_s: 1.2, success: true });
    }
    fixture.detectChanges();    
    expect(compiled.querySelector('#results-table')?.textContent).toContain('1.2');    
    
    tick(1300);
    fixture.detectChanges();
    expect(compiled.querySelector('#trainer-stopwatch')?.textContent).toContain('1.3');
    debug.query(By.css('#stopwatch-stop-and-pause')).triggerEventHandler('click', null);
    fixture.detectChanges();
    {
      const req = httpMock.expectOne({ url: '/api/training_sessions/56/results', method: HttpVerb.Post });
      expect(req.request.body).toEqual({ result: { case_key: 'test case key', num_hints: 0, time_s: 1.3, success: true } });
      req.flush({ id: 2, created_at: '2022-01-01 09:23', casee: { key: 'test case key', name: 'test case name', raw_name: 'raw test case name' }, num_hints: 1, time_s: 1.3, success: true });
    }
    fixture.detectChanges();
    expect(compiled.querySelector('#results-table')?.textContent).toContain('1.2');    
  }));
});
