import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Achievement } from './achievement.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AchievementsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<Achievement[]> {
    return this.rails.get<Achievement[]>('/achievements', {});
  }

  show(achievementKey: string): Observable<Achievement> {
    return this.rails.get<Achievement>(`/achievements/${achievementKey}`, {});
  }
}
