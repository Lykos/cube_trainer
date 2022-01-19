import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { AchievementGrant } from './achievement-grant.model';
import { achievementById } from './achievements.const';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { mapOptional, hasValue, forceValue, Optional } from '@utils/optional'
import { Observable } from 'rxjs';

interface RawAchievementGrant {
  readonly createdAt: string;
  readonly achievementId: string;
}

function parseAchievementGrant(achievementGrant: RawAchievementGrant): Optional<AchievementGrant> {
  return mapOptional(
    achievementById(achievementGrant.achievementId),
    achievement => {
      return {
	timestamp: fromDateString(achievementGrant.createdAt),
	achievement,
      }
    }
  );
}

@Injectable({
  providedIn: 'root',
})
export class AchievementGrantsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<AchievementGrant[]> {
    return this.rails.get<RawAchievementGrant[]>('/achievement_grants', {}).pipe(
      map(achievementGrants => achievementGrants.map(parseAchievementGrant).filter(hasValue).map(forceValue)),
    );
  }
}
