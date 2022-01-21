import { UncalculatedStat } from './uncalculated-stat.model';
import { StatPart } from './stat-part.model';

export interface Stat extends UncalculatedStat {
  readonly parts: StatPart[];
}
