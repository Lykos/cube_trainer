import { StatsService } from '../stats.service';
import { Component, OnInit } from '@angular/core';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';
// @ts-ignore
import Rails from '@rails/ujs';
import { Observable } from 'rxjs';
import { StatsDataSource } from '../stats.data-source';
import { StatPartType } from '../stat-part-type.model';

@Component({
  selector: 'cube-trainer-stats-table',
  templateUrl: './stats-table.component.html',
  styleUrls: ['./stats-table.component.css']
})
export class StatsTableComponent implements OnInit {
  modeId$: Observable<number>;
  dataSource!: StatsDataSource;
  columnsToDisplay = ['name', 'value'];

  public get statPartType(): typeof StatPartType {
    return StatPartType; 
  }

  constructor(private readonly statsService: StatsService,
	      activatedRoute: ActivatedRoute) {
    this.modeId$ = activatedRoute.params.pipe(map(p => +p['modeId']));
  }

  ngOnInit() {
    this.dataSource = new StatsDataSource(this.statsService);
    this.update();
  }

  update() {
    this.modeId$.subscribe(modeId => {
      this.dataSource.loadStats(modeId);
    });
  }
}
