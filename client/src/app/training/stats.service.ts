import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Stat } from './stat.model';
import { StatPart } from './stat-part.model';
import { StatType } from './stat-type.model';
import { switchMap, map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration'
import { fromDateString, Instant } from '@utils/instant'

interface UncalculatedStat {
  readonly id: number;
  readonly index: number;
  readonly timestamp: Instant;
  readonly statType: StatType;
}

function parseStat(stat: any): UncalculatedStat {
  return {
    id: stat.id,
    index: stat.index,
    timestamp: fromDateString(stat.createdAt),
    statType: stat.statType,
  };
}

function calculateStat(stat: UncalculatedStat): Observable<Stat> {
}

@Injectable({
  providedIn: 'root',
})
export class StatsService {
  constructor(private readonly rails: RailsService) {}

  listTypes(): Observable<StatType[]> {
    return this.rails.get<StatType[]>('/stat_types', {});
  }
  
  list(trainingSessionId: number): Observable<Stat[]> {
    return this.rails.get<any[]>(`/training_sessions/${trainingSessionId}/stats`, {}).pipe(
      map(stats => stats.map(parseStat)),
      switchMap(calculateStat),
    );
  }

  destroy(trainingSessionId: number, statId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/stats/${statId}`, {});
  }
}
