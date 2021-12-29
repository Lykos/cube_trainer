import { SelectionModel } from '@angular/cdk/collections';
import { Result } from '../result.model';
import { Component, OnInit, Input, LOCALE_ID, Inject } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { formatDate } from '@angular/common';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { selectSelectedTrainingSessionResults, selectSelectedTrainingSessionNumResults, selectSelectedTrainingSessionResultsOnPage, selectSelectedTrainingSessionNumResultsOnPage, selectSelectedTrainingSessionAnyLoading } from '@store/results.selectors';
import { initialLoad, destroy, markDnf, setSelectedTrainingSessionId, setPage } from '@store/results.actions';
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
    this.loading$ = this.store.select(selectSelectedTrainingSessionAnyLoading);
    this.results$ = this.store.select(selectSelectedTrainingSessionResults);
    this.resultsOnPage$ = this.store.select(selectSelectedTrainingSessionResultsOnPage);
    this.numResults$ = this.store.select(selectSelectedTrainingSessionNumResults);
    this.allSelected$ = this.store.select(selectSelectedTrainingSessionNumResultsOnPage).pipe(
      map(l => { return { value: this.selection.selected.length === l }; }),
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
    this.store.dispatch(setSelectedTrainingSessionId({ selectedTrainingSessionId: this.checkedTrainingSessionId }));
    this.store.dispatch(initialLoad({ trainingSessionId: this.checkedTrainingSessionId }));
  }

  onDeleteSelected() {
    this.store.dispatch(destroy({ trainingSessionId: this.checkedTrainingSessionId, results: this.selection.selected }));
  }

  onMarkSelectedDnf() {
    this.store.dispatch(markDnf({ trainingSessionId: this.checkedTrainingSessionId, results: this.selection.selected }));
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
    return `${this.selection.isSelected(row) ? 'deselect' : 'select'} result from ${formatDate(row.timestamp.toDate(), 'short', this.locale)}`;
  }
}
