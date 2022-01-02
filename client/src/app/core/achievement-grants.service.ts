import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { AchievementGrant } from './achievement-grant.model';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { Observable } from 'rxjs';

interface RawAchievementGrant extends Omit<AchievementGrant, 'timestamp'> {
  readonly createdAt: string;
}

function parseAchievementGrant(achievementGrant: RawAchievementGrant): AchievementGrant {
  return {
    ...achievementGrant,
    timestamp: fromDateString(achievementGrant.createdAt),
  }
}

@Injectable({
  providedIn: 'root',
})
export class AchievementGrantsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<AchievementGrant[]> {
    return this.rails.get<RawAchievementGrant[]>('/achievement_grants', {}).pipe(
      map(achievementGrants => achievementGrants.map(parseAchievementGrant)));
  }
}
