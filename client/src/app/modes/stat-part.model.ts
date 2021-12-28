import { Duration } from '@utils/duration';
import { StatPartType } from './stat-part-type.model';

export interface StatPart {
  readonly statPartType: StatPartType;
  readonly name: string;
  readonly duration: Duration | undefined;
  readonly fraction: number | undefined;
  readonly count: number | undefined;
  readonly success: boolean;
}
