import { Instant } from '@utils/instant';
import { PartialResult } from './partial-result.model';

export interface Result extends PartialResult {
  readonly id: number;
  readonly timestamp: Instant;
  readonly caseKey: string;
  readonly caseName: string;
}
