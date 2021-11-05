import { Instant } from '../utils/instant';
import { StatType } from './stat-type';
import { StatPart } from './stat-part';

export interface Stat {
  readonly id: number;
  readonly index: number;
  readonly timestamp: Instant;
  readonly statType: StatType;
  readonly parts: StatPart[];
}
