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
    statPartType: statPart.stat_part_type,
    duration: statPart.success ? seconds(statPart.time_s) : undefined,
    fraction: statPart.fraction,
    count: statPart.count,
    success: statPart.success,
  }
}

function parseStat(stat: any): Stat {
  return {
    id: stat.id,
    index: stat.index,
    timestamp: fromDateString(stat.created_at),
    statType: stat.stat_type,
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
  
  list(modeId: number): Observable<Stat[]> {
    return this.rails.get<any[]>(`/modes/${modeId}/stats`, {}).pipe(
      map(stats => stats.map(parseStat)));
  }

  destroy(modeId: number, statId: number): Observable<void> {
    return this.rails.delete<void>(`/modes/${modeId}/stats/${statId}`, {});
  }
}
