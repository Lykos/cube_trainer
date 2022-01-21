import { map } from 'rxjs/operators';
import { Component } from '@angular/core';
import { Observable } from 'rxjs';
import { StatPart } from '../stat-part.model';
import { selectStats, selectInitialLoadLoading } from '@store/trainer.selectors';
import { Store } from '@ngrx/store';
import { forceValue } from '@utils/optional';

@Component({
  selector: 'cube-trainer-stats-table',
  templateUrl: './stats-table.component.html',
  styleUrls: ['./stats-table.component.css']
})
export class StatsTableComponent {
  columnsToDisplay = ['name', 'value'];
  stats$: Observable<readonly StatPart[]>;
  loading$: Observable<boolean>;

  constructor(private readonly store: Store) {
    this.loading$ = this.store.select(selectInitialLoadLoading);
    this.stats$ = this.store.select(selectStats).pipe(
      map(forceValue),
      map(ss => ss.flatMap(s => s.parts)),
    );
  }
  
  statId(index: number, stat: StatPart) {
    return stat.name;
  }
}
