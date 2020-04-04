import { ResultService } from './result.service';
import { Component, AfterViewInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable } from 'rxjs';
import { Result } from './result';
import { MatTableDataSource } from '@angular/material/table';

@Component({
  selector: 'result-table',
  template: `
<mat-card>
  <mat-card-title>Results</mat-card-title>
  <mat-card-content>
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
export class ResultTableComponent implements AfterViewInit {
  modeId: Observable<number>;
  dataSource = new MatTableDataSource<Result>();
  
  constructor(private readonly resultService: ResultService,
	      activatedRoute: ActivatedRoute) {
    this.modeId = activatedRoute.params.pipe(map(p => p.modeId));
  }

  ngAfterViewInit() {
    this.modeId.subscribe(modeId => {
      this.resultService.list(modeId).subscribe(results => this.dataSource.data = results);
    });
  }
}
