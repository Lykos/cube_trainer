import { StatsService } from './stats.service';
import { Component, OnInit, OnDestroy, Input } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable, Subscription } from 'rxjs';
import { StatsDataSource } from './stats.data-source';
import { StatPartType } from './stat-part-type';

@Component({
  selector: 'cube-trainer-stats-table',
  templateUrl: './stats-table.component.html',
  styleUrls: ['./stats-table.component.css']
})
export class StatsTableComponent implements OnInit, OnDestroy {
  modeId$: Observable<number>;
  dataSource!: StatsDataSource;
  columnsToDisplay = ['name', 'value'];
  @Input() statEvents$!: Observable<void>;
  private eventsSubscription!: Subscription;

  public get statPartType(): typeof StatPartType {
    return StatPartType; 
  }

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
