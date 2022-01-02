import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { AchievementGrant } from './achievement-grant.model';
import { Achievement } from './achievement.model';
import { checkAchievement } from './achievements.service';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { Observable } from 'rxjs';
import { FieldMissingError, FieldTypeError } from '@shared/rails-parse-error';

interface RawAchievementGrant {
  readonly achievement?: unknown;
  readonly createdAt?: unknown;
}

function parseAchievementGrant(achievementGrant: RawAchievementGrant): AchievementGrant {
  if (achievementGrant.achievement === undefined) {
    throw new FieldMissingError('achievement', 'achievement grant', achievementGrant);
  }
  if (typeof achievementGrant.achievement !== 'object') {
    throw new FieldTypeError('achievement', 'object', 'achievement grant', achievementGrant);
  }
  if (achievementGrant.createdAt === undefined) {
    throw new FieldMissingError('createdAt', 'achievement grant', achievementGrant);
  }
  if (typeof achievementGrant.createdAt !== 'string') {
    throw new FieldTypeError('createdAt', 'object', 'achievement grant', achievementGrant);
  }
  return {
    achievement: checkAchievement(achievementGrant.achievement as Partial<Achievement>),
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
