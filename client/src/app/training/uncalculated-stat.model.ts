import { Instant } from '@utils/instant';
import { StatType } from './stat-type.model';

export interface UncalculatedStat {
  readonly id: number;
  readonly index: number;
  readonly timestamp: Instant;
  readonly statType: StatType;
}
