import { filterPresent } from '@shared/operators';
import { SelectionModel } from '@angular/cdk/collections';
import { Result } from '../result.model';
import { Component, Input, LOCALE_ID, Inject } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { formatDate } from '@angular/common';
import { fromDateString, Instant, now } from '@utils/instant';
import { seconds, Duration } from '@utils/duration';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { selectResults, selectResultsTotal, selectResultsOnPage, selectInitialLoadLoading, selectPageSize } from '@store/trainer.selectors';
import { destroy, markDnf, setPage } from '@store/trainer.actions';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-results-table',
  templateUrl: './results-table.component.html',
  styleUrls: ['./results-table.component.css']
})
export class ResultsTableComponent {
  @Input()
  trainingSessionId?: number;

  columnsToDisplay = ['select', 'case', 'time', 'numHints', 'timestamp'];
  results$: Observable<readonly Result[]>;
  resultsOnPage$: Observable<readonly Result[]>;
  loading$: Observable<boolean>;
  numResults$: Observable<number>;
  pageSize$: Observable<number>;

  selection = new SelectionModel<Result>(true, []);

  constructor(private readonly store: Store,
	      @Inject(LOCALE_ID) private readonly locale: string) {
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.results$ = this.store.select(selectResults).pipe(filterPresent());
    this.resultsOnPage$ = this.store.select(selectResultsOnPage).pipe(
      filterPresent(),
      tap(() => this.selection.clear())
    );
    this.numResults$ = this.store.select(selectResultsTotal).pipe(filterPresent());
    this.pageSize$ = this.store.select(selectPageSize);
  }

  now() {
    return now();
  }

  get checkedTrainingSessionId(): number {
    const trainingSessionId = this.trainingSessionId;
    if (!trainingSessionId) {
      throw new Error('trainingSessionId has to be defined');
    }
    return trainingSessionId;
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

  allSelected(resultsOnPage: readonly Result[]) {
    return this.selection.selected.length === resultsOnPage.length;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle(resultsOnPage: readonly Result[]) {
    if (this.allSelected(resultsOnPage)) {
      this.selection.clear();
    } else {
      resultsOnPage.forEach(row => this.selection.select(row));
    }
  }

  masterCheckboxLabel(resultsOnPage: readonly Result[]): string {
    return `${this.allSelected(resultsOnPage) ? 'select' : 'deselect'} all`;
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(row: Result): string {
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
