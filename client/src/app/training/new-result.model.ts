import { Case } from './case.model';

export interface NewResult {
  readonly timeS: number;
  readonly casee: Case;
  readonly success: boolean;
  readonly numHints: number;
}
