import { SelectionModel } from '@angular/cdk/collections';
import { ResultsService } from '../results.service';
import { Result } from '../result.model';
import { Component, OnInit, OnDestroy, Input, Output, EventEmitter, LOCALE_ID, Inject } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { formatDate } from '@angular/common';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subscription, zip } from 'rxjs';
import { ResultsDataSource } from '../results.data-source';

@Component({
  selector: 'cube-trainer-results-table',
  templateUrl: './results-table.component.html',
  styleUrls: ['./results-table.component.css']
})
export class ResultsTableComponent implements OnInit, OnDestroy {
  modeId$: Observable<number>;
  dataSource!: ResultsDataSource;
  columnsToDisplay = ['select', 'input', 'time', 'numHints', 'timestamp'];

  @Input() resultEvents$!: Observable<void>;

  @Output()
  private resultsModified: EventEmitter<void> = new EventEmitter();

  private eventsSubscription!: Subscription;
  selection = new SelectionModel<Result>(true, []);

  constructor(private readonly resultsService: ResultsService,
	      private readonly snackBar: MatSnackBar,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p['modeId']));
  }

  ngOnInit() {
    this.dataSource = new ResultsDataSource(this.resultsService);
    this.eventsSubscription = this.resultEvents$.subscribe(() => this.update());
    this.update();
  }

  update() {
    this.modeId$.subscribe(modeId => {
      this.dataSource.loadResults(modeId);
    });
  }

  ngOnDestroy() {
    this.eventsSubscription.unsubscribe();
  }

  onDeleteSelected() {
    this.modeId$.subscribe(modeId => {
      const observables = this.selection.selected.map(result =>
	this.resultsService.destroy(modeId, result.id));
      zip(...observables).subscribe((voids) => {
	this.selection.clear();
	this.snackBar.open(`Deleted ${observables.length} results!`, 'Close');
        this.resultsModified.emit();
      });
    });
  }

  onMarkSelectedDnf() {
    this.modeId$.subscribe(modeId => {
      const observables = this.selection.selected.map(result =>
	this.resultsService.markDnf(modeId, result.id));
      zip(...observables).subscribe((voids) => {
	this.selection.clear();
	this.snackBar.open(`Marked ${observables.length} results as DNF!`, 'Close');
        this.resultsModified.emit();
      });
    });
  }

  /** Whether the number of selected elements matches the total number of rows. */
  get allSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.data.length;
    return numSelected === numRows;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle() {
    this.allSelected ?
      this.selection.clear() :
      this.dataSource.data.forEach(row => this.selection.select(row));
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(row?: Result): string {
    if (!row) {
      return `${this.allSelected ? 'select' : 'deselect'} all`;
    }
    return `${this.selection.isSelected(row) ? 'deselect' : 'select'} result from ${formatDate(row.timestamp.toDate(), 'short', this.locale)}`;
  }
}
