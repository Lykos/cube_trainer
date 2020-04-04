import { ResultService } from './result.service';
import { Component, OnInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable } from 'rxjs';
import { Result } from './result';

@Component({
  selector: 'result-table',
  template: `
<mat-card>
  <mat-card-title>Results</mat-card-title>
  <mat-card-content>
    <table mat-table [dataSource]="results">
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
      <tr mat-row *matRowDef="let mode; columns: columnsToDisplay"></tr>
    </table>
  </mat-card-content>
</mat-card>
`
})
export class ResultTableComponent implements OnInit {
  results: Result[] = [];
  modeId: Observable<number>;

  constructor(private readonly resultService: ResultService,
	      activatedRoute: ActivatedRoute) {
    this.modeId = activatedRoute.params.pipe(map(p => p.modeId));
  }

  ngOnInit() {
    this.modeId.subscribe(modeId => {
      this.resultService.list(modeId).subscribe(results => this.results = results);
    });
  }
}
