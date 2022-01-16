import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { StatType } from './stat-type.model';

@Injectable({
  providedIn: 'root',
})
export class StatsService {
  constructor(private readonly rails: RailsService) {}

  listTypes(): Observable<StatType[]> {
    return this.rails.get<StatType[]>('/stat_types', {});
  }

  destroy(trainingSessionId: number, statId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/stats/${statId}`, {});
  }
}
