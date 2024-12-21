import { filterPresent } from '@shared/operators';
import { SelectionModel } from '@angular/cdk/collections';
import { Result } from '../result.model';
import { Component, Input, LOCALE_ID, Inject, OnInit, OnDestroy } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { formatDate, AsyncPipe } from '@angular/common';
import { fromDateString, Instant, now } from '@utils/instant';
import { seconds, Duration } from '@utils/duration';
import { Observable, Subscription } from 'rxjs';
import { tap, map, distinctUntilChanged } from 'rxjs/operators';
import { selectResults, selectResultsTotal, selectResultsOnPage, selectInitialLoadLoading, selectPageSize } from '@store/trainer.selectors';
import { destroy, markDnf, setPage } from '@store/trainer.actions';
import { Store } from '@ngrx/store';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { DurationPipe } from '../../shared/duration.pipe';
import { InstantPipe } from '../../shared/instant.pipe';
import { FluidInstantPipe } from '../../shared/fluid-instant.pipe';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatButtonModule } from '@angular/material/button';

const IMPORTANT_COLUMNS = ['select', 'case', 'time'];
const ALL_COLUMNS = IMPORTANT_COLUMNS.concat(['numHints', 'timestamp']);

@Component({
  selector: 'cube-trainer-results-table',
  templateUrl: './results-table.component.html',
  styleUrls: ['./results-table.component.css'],
  imports: [
    AsyncPipe,
    DurationPipe,
    InstantPipe,
    FluidInstantPipe,
    MatPaginatorModule,
    MatTableModule,
    MatTooltipModule,
    MatCheckboxModule,
    MatProgressSpinnerModule,
    MatButtonModule,
  ],
})
export class ResultsTableComponent implements OnInit, OnDestroy {
  @Input()
  trainingSessionId?: number;

  columnsToDisplay = ALL_COLUMNS;
  results$: Observable<readonly Result[]>;
  resultsOnPage$: Observable<readonly Result[]>;
  loading$: Observable<boolean>;
  numResults$: Observable<number>;
  pageSize$: Observable<number>;
  showUnimportantColumns$: Observable<boolean>;

  selection = new SelectionModel<Result>(true, []);
  showUnimportantColumnsSubscription?: Subscription;

  constructor(private readonly store: Store,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      breakpointObserver: BreakpointObserver) {
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.results$ = this.store.select(selectResults).pipe(filterPresent());
    this.resultsOnPage$ = this.store.select(selectResultsOnPage).pipe(
      filterPresent(),
      tap(() => this.selection.clear())
    );
    this.numResults$ = this.store.select(selectResultsTotal).pipe(filterPresent());
    this.pageSize$ = this.store.select(selectPageSize);
    this.showUnimportantColumns$ = breakpointObserver.observe([Breakpoints.XSmall, Breakpoints.Small]).pipe(
      distinctUntilChanged(),
      map(breakpointState => !breakpointState.matches)
    );
  }

  ngOnInit() {
    this.showUnimportantColumnsSubscription = this.showUnimportantColumns$.subscribe(showUnimportantColumns => {
      if (showUnimportantColumns) {
	this.columnsToDisplay = ALL_COLUMNS;
      } else {
	this.columnsToDisplay = IMPORTANT_COLUMNS;
      }
    });
  }

  ngOnDestroy() {
    this.showUnimportantColumnsSubscription?.unsubscribe();
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
