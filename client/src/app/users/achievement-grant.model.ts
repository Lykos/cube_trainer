import { Achievement } from './achievement.model';
import { Instant } from '../utils/instant';

export interface AchievementGrant {
  timestamp: Instant;
  achievement: Achievement;
}
