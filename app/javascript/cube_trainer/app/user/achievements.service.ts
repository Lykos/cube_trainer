import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Achievement } from './achievement';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AchievementsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<Achievement[]> {
    return this.rails.ajax<Achievement[]>(HttpVerb.Get, '/achievements', {});
  }

  show(achievementId: number): Observable<Achievement> {
    return this.rails.ajax<Achievement>(HttpVerb.Get, `/achievements/${achievementId}`, {});
  }
}
