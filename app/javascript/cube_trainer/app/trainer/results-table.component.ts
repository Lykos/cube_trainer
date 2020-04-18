import { SelectionModel } from '@angular/cdk/collections';
import { ResultService } from './results.service';
import { Result } from './result';
import { Component, OnInit, OnDestroy, Input, LOCALE_ID, Inject } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
import { formatDate } from '@angular/common';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subscription, zip } from 'rxjs';
import { ResultsDataSource } from './results.data-source';

@Component({
  selector: 'results-table',
  template: `
<div>
  <h2>Results</h2>
  <div>
    <div class="spinner-container" *ngIf="dataSource.loading$ | async">
      <mat-spinner></mat-spinner>
    </div>
    <table mat-table class="mat-elevation-z2" [dataSource]="dataSource" matRipple [matRippleTrigger]="deleteButton">
      <ng-container matColumnDef="select">
        <th mat-header-cell *matHeaderCellDef>
          <mat-checkbox (change)="$event ? masterToggle() : null"
                        [checked]="selection.hasValue() && allSelected"
                        [indeterminate]="selection.hasValue() && !allSelected"
                        [aria-label]="checkboxLabel()">
          </mat-checkbox>
        </th>
        <td mat-cell *matCellDef="let result">
          <mat-checkbox (click)="$event.stopPropagation()"
                        (change)="$event ? selection.toggle(result) : null"
                        [checked]="selection.isSelected(result)"
                        [aria-label]="checkboxLabel(result)">
          </mat-checkbox>
        </td>
      </ng-container>
      <ng-container matColumnDef="timestamp">
        <th mat-header-cell *matHeaderCellDef> Timestamp </th>
        <td mat-cell *matCellDef="let result"> {{result.timestamp | instant}} </td>
      </ng-container>
      <ng-container matColumnDef="input">
        <th mat-header-cell *matHeaderCellDef> Input </th>
        <td mat-cell *matCellDef="let result"> {{result.inputRepresentation}} </td>
      </ng-container>
      <ng-container matColumnDef="time">
        <th mat-header-cell *matHeaderCellDef> Time </th>
        <td mat-cell *matCellDef="let result"> {{result.duration | duration}} </td>
      </ng-container>
      <ng-container matColumnDef="numHints">
        <th mat-header-cell *matHeaderCellDef> Num Hints </th>
        <td mat-cell *matCellDef="let result"> {{result.numHints}} </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let result; columns: columnsToDisplay"></tr>
    </table>
    <button #deleteButton mat-fab (click)="onDeleteSelected()" *ngIf="selection.hasValue()">
      <span class="material-icons">delete</span>
    </button>
  </div>
</div>
`,
  styles: [`
table {
  width: 100%;
}
.mat-column-select {
  overflow: initial;
}
`]
})
export class ResultsTableComponent implements OnInit, OnDestroy {
  modeId$: Observable<number>;
  dataSource!: ResultsDataSource;
  columnsToDisplay = ['select', 'timestamp', 'input', 'time', 'numHints'];
  @Input() resultEvents$!: Observable<void>;
  private eventsSubscription!: Subscription;
  private selection = new SelectionModel<Result>(true, []);

  constructor(private readonly resultsService: ResultService,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p.modeId));
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
	this.update();
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
