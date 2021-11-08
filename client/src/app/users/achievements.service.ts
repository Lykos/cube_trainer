import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Achievement } from './achievement.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AchievementsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<Achievement[]> {
    return this.rails.ajax<Achievement[]>(HttpVerb.Get, '/achievements', {});
  }

  show(achievementKey: string): Observable<Achievement> {
    return this.rails.ajax<Achievement>(HttpVerb.Get, `/achievements/${achievementKey}`, {});
  }
}
