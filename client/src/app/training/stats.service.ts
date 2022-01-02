import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Stat } from './stat.model';
import { StatPart } from './stat-part.model';
import { StatType } from './stat-type.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration'
import { fromDateString } from '@utils/instant'

function parseStatPart(statPart: any): StatPart {
  return {
    name: statPart.name,
    statPartType: statPart.statPartType,
    duration: statPart.success ? seconds(statPart.timeS) : undefined,
    fraction: statPart.fraction,
    count: statPart.count,
    success: statPart.success,
  }
}

function parseStat(stat: any): Stat {
  return {
    id: stat.id,
    index: stat.index,
    timestamp: fromDateString(stat.createdAt),
    statType: stat.statType,
    parts: stat.stat_parts.map(parseStatPart),
  };
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
      map(stats => stats.map(parseStat)));
  }

  destroy(trainingSessionId: number, statId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/stats/${statId}`, {});
  }
}
