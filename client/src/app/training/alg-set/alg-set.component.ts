import { Component, OnInit } from '@angular/core';
import { distinctUntilChanged, map, take } from 'rxjs/operators';
import { filterPresent } from '@shared/operators';
import { TrainingCase } from '../training-case.model';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { BackendActionError } from '@shared/backend-action-error.model';
import { initialLoadSelected } from '@store/trainer.actions';
import { FileSaverService } from 'ngx-filesaver';
import { selectSelectedTrainingSession, selectInitialLoadLoading, selectInitialLoadError } from '@store/training-sessions.selectors';

const EOL = "\r\n";
const COMMA = ",";
const QUOTE_REGEXP = /"/g;
const DOUBLE_QUOTE = '""';
const SPECIAL_CHARACTERS_REGEXP = /[",\r\n]/m;

function escapeCsvCell(cell: string): string {
  if (!SPECIAL_CHARACTERS_REGEXP.test(cell)) {
    return cell;
  }
  return `"${cell.replace(QUOTE_REGEXP, DOUBLE_QUOTE)}"`;
}

function toCsvRow(row: string[]): string {
  return row.map(escapeCsvCell).join(COMMA);
}

function toCsv(table: string[][]): string {
  return table.map(toCsvRow).join(EOL);
}

@Component({
  selector: 'cube-trainer-alg-set',
  templateUrl: './alg-set.component.html',
  styleUrls: ['./alg-set.component.css']
})
export class AlgSetComponent implements OnInit {
  columnsToDisplay = ['case', 'alg', 'algSource'];
  trainingCases$: Observable<readonly TrainingCase[]>;
  loading$: Observable<boolean>;
  error$: Observable<BackendActionError>;

  constructor(private readonly store: Store,
              private readonly fileSaverService: FileSaverService) {
    this.trainingCases$ = this.store.select(selectSelectedTrainingSession).pipe(
      distinctUntilChanged(),
      filterPresent(),
      map(m => m.trainingCases),
    );
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.error$ = this.store.select(selectInitialLoadError).pipe(filterPresent());
  }

  trainingCaseKey(index: number, trainingCase: TrainingCase) {
    return trainingCase.casee.key;
  }

  onDownloadAlgSetCsv() {
    this.trainingCases$.pipe(
      take(1),
    ).subscribe(trainingCases => {
      const table = trainingCases.map(t => [t.casee.name, t.alg || '']);
      const blob = new Blob([toCsv(table)], {type: "text/csv;charset=utf-8"});
      this.fileSaverService.save(blob, 'alg-set.csv');
    });
  }

  ngOnInit() {
    this.store.dispatch(initialLoadSelected());
  }
}
