import { RailsService } from '../core/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../core/http-verb';
import { AchievementGrant } from './achievement-grant.model';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AchievementGrantsService {
  constructor(private readonly rails: RailsService) {}

  parseAchievementGrant(achievementGrant: any): AchievementGrant {
    return {
      achievement: achievementGrant.achievement,
      timestamp: fromDateString(achievementGrant.created_at),
    }
  }

  list(): Observable<AchievementGrant[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, '/achievement_grants', {}).pipe(
      map(achievementGrants => achievementGrants.map(this.parseAchievementGrant)));
  }
}
