import { Achievement } from './achievement';
import { Instant } from '../utils/instant';

export interface AchievementGrant {
  timestamp: Instant;
  achievement: Achievement;
}
