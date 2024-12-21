import { FileSaverService } from 'ngx-filesaver';
import { By } from '@angular/platform-browser';
import { ActivatedRoute } from '@angular/router';
import { TestBed } from '@angular/core/testing';
import { AlgSetComponent } from './alg-set.component';
import { TrainingCase } from '../training-case.model';
import { TrainingSession } from '../training-session.model';
import { ShowInputMode } from '../show-input-mode.model';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';
import { provideMockStore, MockStore } from '@ngrx/store/testing';
import { GeneratorType } from '../generator-type.model';
import { of } from 'rxjs';
import { none, some } from '@utils/optional';
import { SharedModule } from '@shared/shared.module';

class ArgumentSaver {
  argument: any;

  asymmetricMatch(argument: any) {
    this.argument = argument;
    return true;
  }

  jasmineToString(): string {
    return '<argumentSaver>';
  }
}

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

const itemAa: TrainingCase = {
  casee: {
    key: 'key AA',
    name: 'name AA',
    rawName: 'raw AA',
  },
  alg: 'alg AA',
  algSource: { tag: 'original' },
};

const itemAb: TrainingCase = {
  casee: {
    key: 'key AB',
    name: 'name AB',
    rawName: 'key AB',
  },
  alg: 'alg AB',
  algSource: { tag: 'inferred' },
};

const itemBa: TrainingCase = {
  casee: {
    key: 'key BA',
    name: 'name BA',
    rawName: 'raw BA',
  },
  alg: 'alg BA',
  algSource: { tag: 'fixed' },
};

const itemBb: TrainingCase = {
  casee: {
    key: 'key BB',
    name: 'name BB',
    rawName: 'raw BB',
  },
  alg: 'alg BB',
  algSource: { tag: 'overridden', algOverrideId: 145 },
};

const trainingSession: TrainingSession = {
  id: 1,
  name: 'test session',
  trainingCases: [itemAa, itemAb, itemBa, itemBb],
  known: false,
  showInputMode: ShowInputMode.Name,
  generatorType: GeneratorType.Case,
  stats: [],
};

const escapedItem: TrainingCase = {
  casee: {
    key: ',',
    name: ',',
    rawName: ',',
  },
  alg: '"',
}

const multiEscapedItem: TrainingCase = {
  casee: {
    key: ',",',
    name: ',",',
    rawName: ',",',
  },
  alg: '"adsf"asdf"asdf"',
}

const multilineItem: TrainingCase = {
  casee: {
    key: "\n",
    name: "\n",
    rawName: "\n",
  },
  alg: "\r",
}

const emptyItem: TrainingCase = {
  casee: {
    key: '',
    name: '',
    rawName: '',
  },
}

const trainingSessionWithEscapedAlg: TrainingSession = {
  ...trainingSession,
  trainingCases: [escapedItem, multiEscapedItem, multilineItem, emptyItem],
}

describe('AlgSetComponent', () => {
  let fileSaverService: any;
  let store: MockStore;

  beforeEach(async () => {
    fileSaverService = jasmine.createSpyObj('FileSaverService', ['save']);
    await TestBed.configureTestingModule({
      imports: [
	SharedModule,
        AlgSetComponent,
    ],
    providers: [
        { provide: ActivatedRoute, useValue: { params: of({ trainingSessionId: 1 }) } },
        { provide: FileSaverService, useValue: fileSaverService },
        provideMockStore({}),
    ],
}).compileComponents();

    store = TestBed.inject(MockStore);
  });

  it('should create', () => {
    const fixture = TestBed.createComponent(AlgSetComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should initially be loading', () => {
    store.overrideSelector(selectSelectedTrainingSession, none);
    store.overrideSelector(selectInitialLoadLoading, true);
    store.overrideSelector(selectInitialLoadError, none);
    const fixture = TestBed.createComponent(AlgSetComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#alg-set-initial-load-loading')).toBeTruthy();
  });

  it('should show an error if initial loading failed', () => {
    store.overrideSelector(selectSelectedTrainingSession, none);
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, some(exampleError('stuff went wrong')));
    const fixture = TestBed.createComponent(AlgSetComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#alg-set-initial-load-error')?.textContent).toContain('stuff went wrong');
  });

  it('should show the table in case of success', () => {
    store.overrideSelector(selectSelectedTrainingSession, some(trainingSession));
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, none);
    const fixture = TestBed.createComponent(AlgSetComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#alg-set-table')?.textContent).toMatch(/.*name AA.*alg AA.*original.*name AB.*alg AB.*inferred.*name BA.*alg BA.*fixed.*name BB.*alg BB.*overridden.*/);
  });

  it('should download a CSV', async () => {
    store.overrideSelector(selectSelectedTrainingSession, some(trainingSession));
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, none);
    const fixture = TestBed.createComponent(AlgSetComponent);
    fixture.detectChanges();
    const button = fixture.debugElement.query(By.css('#download-alg-set-csv')).nativeElement;

    button.click();
    fixture.detectChanges();

    const saver = new ArgumentSaver();
    expect(fileSaverService.save).toHaveBeenCalledWith(saver, 'alg-set.csv');
    const text = await saver.argument.text();
    expect(text).toEqual("name AA,alg AA\r\nname AB,alg AB\r\nname BA,alg BA\r\nname BB,alg BB");
  });

  it('should download a CSV with escaped data', async () => {
    store.overrideSelector(selectSelectedTrainingSession, some(trainingSessionWithEscapedAlg));
    store.overrideSelector(selectInitialLoadLoading, false);
    store.overrideSelector(selectInitialLoadError, none);
    const fixture = TestBed.createComponent(AlgSetComponent);
    fixture.detectChanges();
    const button = fixture.debugElement.query(By.css('#download-alg-set-csv')).nativeElement;

    button.click();
    fixture.detectChanges();

    const saver = new ArgumentSaver();
    expect(fileSaverService.save).toHaveBeenCalledWith(saver, 'alg-set.csv');
    const text = await saver.argument.text();
    expect(text).toEqual(
      '",",""""' + "\r\n" +
	'","",","""adsf""asdf""asdf"""' + "\r\n" +
	"\"\n\",\"\r\"\r\n" +
	",");
  });
});
