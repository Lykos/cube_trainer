import { ActivatedRoute } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { TestBed } from '@angular/core/testing';
import { TrainerComponent } from './trainer.component';
import { TrainerService } from '../trainer.service';
import { provideMockStore, MockStore } from '@ngrx/store/testing';
import { of } from 'rxjs';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { none, some } from '@utils/optional';
import { BackendActionLoadErrorComponent } from '@shared/backend-action-load-error/backend-action-load-error.component';

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

describe('TrainerComponent', () => {
  let trainerService, matDialog: any;
  let store: MockStore;

  beforeEach(async () => {
    trainerService = jasmine.createSpyObj('TrainerService', ['randomCase', 'randomScramble']);
    matDialog = jasmine.createSpyObj('MatDialog', ['open']);

    await TestBed.configureTestingModule({
      declarations: [
        TrainerComponent,
        BackendActionLoadErrorComponent,
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
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#initialLoadLoading')).toBeTruthy();
  });

  it('should display an error if initial loading failed', () => {
    store.overrideSelector(selectSelectedTrainingSession, none);
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, some(exampleError('stuff went wrong')));
    const fixture = TestBed.createComponent(TrainerComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    console.log(compiled);
    expect(compiled.querySelector('#initialLoadError')?.textContent).toContain('stuff went wrong');
  });
});
