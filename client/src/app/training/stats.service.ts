import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Stat } from './stat.model';
import { StatPart } from './stat-part.model';
import { StatType } from './stat-type.model';
import { switchMap, map } from 'rxjs/operators';
import { Observable, of, forkJoin } from 'rxjs';
import { fromDateString, Instant } from '@utils/instant'

interface UncalculatedStat {
  readonly id: number;
  readonly index: number;
  readonly timestamp: Instant;
  readonly statType: StatType;
}

interface StatCalculator {
  calculate(trainingSessionId: number): Observable<StatPart[]>;
}

const statCalculators: Map<string, StatCalculator> = new Map();

function parseStat(stat: any): UncalculatedStat {
  return {
    id: stat.id,
    index: stat.index,
    timestamp: fromDateString(stat.createdAt),
    statType: stat.statType,
  };
}

function calculateStatParts(stat: UncalculatedStat, trainingSessionId: number): Observable<Stat> {
  const calculator = statCalculators.get(stat.statType.id);
  const parts$: Observable<StatPart[]> = calculator ? calculator.calculate(trainingSessionId) : of([]);
  return parts$.pipe(map(parts => ({ ...stat, parts })));
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
      switchMap(ss => forkJoin(ss.map(s => calculateStatParts(s, trainingSessionId)))),
    );
  }

  destroy(trainingSessionId: number, statId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/stats/${statId}`, {});
  }
}
