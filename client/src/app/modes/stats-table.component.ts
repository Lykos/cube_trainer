import { StatsService } from './stats.service';
import { Component, OnInit, OnDestroy, Input } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subscription } from 'rxjs';
import { StatsDataSource } from './stats.data-source';

@Component({
  selector: 'stats-table',
  template: `
<div *ngIf="dataSource.data.length > 0">
  <h2>Stats</h2>
  <div>
    <div class="spinner-container" *ngIf="dataSource.loading$ | async">
      <mat-spinner></mat-spinner>
    </div>
    <table mat-table class="mat-elevation-z2" [dataSource]="dataSource">
      <mat-text-column name="name"></mat-text-column>
      <ng-container matColumnDef="time">
        <th mat-header-cell *matHeaderCellDef> Time </th>
        <td mat-cell *matCellDef="let stat"> {{stat.success ? (stat.duration | duration) : 'DNF'}} </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let stat; columns: columnsToDisplay"></tr>
    </table>
  </div>
</div>
`,
  styles: [`
table {
  width: 100%;
}
`]
})
export class StatsTableComponent implements OnInit, OnDestroy {
  modeId$: Observable<number>;
  dataSource!: StatsDataSource;
  columnsToDisplay = ['name', 'time'];
  @Input() statEvents$!: Observable<void>;
  private eventsSubscription!: Subscription;

  constructor(private readonly statsService: StatsService,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => p['modeId']));
  }

  ngOnInit() {
    this.dataSource = new StatsDataSource(this.statsService);
    this.eventsSubscription = this.statEvents$.subscribe(() => this.update());
    this.update();
  }

  update() {
    this.modeId$.subscribe(modeId => {
      this.dataSource.loadStats(modeId);
    });
  }

  ngOnDestroy() {
    this.eventsSubscription.unsubscribe();
  }
}
