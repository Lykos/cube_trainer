import { SelectionModel } from '@angular/cdk/collections';
import { Result } from '../result.model';
import { Component, OnInit, Input, LOCALE_ID, Inject } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { formatDate } from '@angular/common';
import { fromDateString, Instant } from '@utils/instant';
import { seconds, Duration } from '@utils/duration';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { forceValue } from '@utils/optional';
import { selectResults, selectResultsTotal, selectResultsOnPage, selectResultsTotalOnPage, selectInitialLoadLoading } from '@store/trainer.selectors';
import { initialLoad, destroy, markDnf, setPage } from '@store/trainer.actions';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-results-table',
  templateUrl: './results-table.component.html',
  styleUrls: ['./results-table.component.css']
})
export class ResultsTableComponent implements OnInit {
  @Input()
  trainingSessionId?: number;

  columnsToDisplay = ['select', 'case', 'time', 'numHints', 'timestamp'];
  results$: Observable<readonly Result[]>;
  resultsOnPage$: Observable<readonly Result[]>;
  loading$: Observable<boolean>;
  numResults$: Observable<number>;
  /** Whether the number of selected elements matches the total number of rows. */
  allSelected$: Observable<{ value: boolean }>;

  selection = new SelectionModel<Result>(true, []);

  constructor(private readonly store: Store,
	      @Inject(LOCALE_ID) private readonly locale: string) {
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.results$ = this.store.select(selectResults).pipe(map(forceValue));
    this.resultsOnPage$ = this.store.select(selectResultsOnPage).pipe(map(forceValue));
    this.numResults$ = this.store.select(selectResultsTotal).pipe(map(forceValue));
    this.allSelected$ = this.store.select(selectResultsTotalOnPage).pipe(
      map(l => { return { value: this.selection.selected.length === forceValue(l) }; }),
      shareReplay(),
    );
  }

  get checkedTrainingSessionId(): number {
    const trainingSessionId = this.trainingSessionId;
    if (!trainingSessionId) {
      throw new Error('trainingSessionId has to be defined');
    }
    return trainingSessionId
  }

  ngOnInit() {
    this.store.dispatch(initialLoad({ trainingSessionId: this.checkedTrainingSessionId }));
  }

  onDeleteSelected() {
    this.store.dispatch(destroy({ trainingSessionId: this.checkedTrainingSessionId, resultIds: this.selection.selected.map(r => r.id) }));
  }

  onMarkSelectedDnf() {
    this.store.dispatch(markDnf({ trainingSessionId: this.checkedTrainingSessionId, resultIds: this.selection.selected.map(r => r.id) }));
  }

  onPage(pageEvent: PageEvent) {
    this.store.dispatch(setPage({ pageSize: pageEvent.pageSize, pageIndex: pageEvent.pageIndex }));
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle(resultsOnPage: readonly Result[], allSelected: boolean) {
    if (allSelected) {
      this.selection.clear();
    } else {
      resultsOnPage.forEach(row => this.selection.select(row));
    }
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(allSelected: boolean, row?: Result): string {
    if (!row) {
      return `${allSelected ? 'select' : 'deselect'} all`;
    }
    return `${this.selection.isSelected(row) ? 'deselect' : 'select'} result from ${formatDate(this.timestamp(row).toDate(), 'short', this.locale)}`;
  }

  duration(result: Result): Duration {
    return seconds(result.timeS);
  }

  timestamp(result: Result): Instant {
    return fromDateString(result.createdAt);
  }

  resultId(index: number, result: Result) {
    return result.id;
  }
}
