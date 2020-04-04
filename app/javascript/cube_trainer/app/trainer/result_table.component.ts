import { ResultService } from './result.service';
import { Component, OnInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable } from 'rxjs';
import { ResultsDataSource } from './results_data_source';

@Component({
  selector: 'result-table',
  template: `
<mat-card>
  <mat-card-title>Results</mat-card-title>
  <mat-card-content>
    <div class="spinner-container" *ngIf="dataSource.loading$ | async">
      <mat-spinner></mat-spinner>
    </div>
    <table #resultTable mat-table [dataSource]="dataSource">
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
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let result; columns: columnsToDisplay"></tr>
    </table>
  </mat-card-content>
</mat-card>
`
})
export class ResultTableComponent implements OnInit {
  modeId: Observable<number>;
  dataSource: ResultsDataSource;
  
  constructor(resultService: ResultService,
	      activatedRoute: ActivatedRoute) {
    this.modeId = activatedRoute.params.pipe(map(p => p.modeId));
    this.dataSource = new ResultsDataSource(resultService);
  }

  ngOnInit() {
    this.modeId.subscribe(modeId => {
      this.dataSource.loadResults(modeId);
    });
  }
}
