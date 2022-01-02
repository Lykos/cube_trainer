import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Achievement } from './achievement.model';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { FieldMissingError, FieldTypeError } from '@shared/rails-parse-error';

export function checkAchievement(partial: Partial<Achievement>): Achievement {
  if (partial.key === undefined) {
    throw new FieldMissingError('key', 'achievement', partial);
  }
  if (typeof partial.key !== 'string') {
    throw new FieldTypeError('key', 'string', 'achievement', partial);
  }
  if (partial.name === undefined) {
    throw new FieldMissingError('name', 'achievement', partial);
  }
  if (typeof partial.name !== 'string') {
    throw new FieldTypeError('name', 'string', 'achievement', partial);
  }
  if (partial.description === undefined) {
    throw new FieldMissingError('description', 'achievement', partial);
  }
  if (typeof partial.description !== 'string') {
    throw new FieldTypeError('description', 'string', 'achievement', partial);
  }
  return {
    key: partial.key,
    name: partial.name,
    description: partial.description,
  };
}

@Injectable({
  providedIn: 'root',
})
export class AchievementsService {
  constructor(private readonly rails: RailsService) {}

  list(): Observable<Achievement[]> {
    return this.rails.get<Achievement[]>('/achievements', {});
  }

  show(achievementKey: string): Observable<Achievement> {
    return this.rails.get<Partial<Achievement>>(`/achievements/${achievementKey}`, {}).pipe(map(checkAchievement));
  }
}
