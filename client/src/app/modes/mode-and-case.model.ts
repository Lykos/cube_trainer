import { Mode } from './mode.model';
import { Case } from '../trainer/case.model';

export interface ModeAndCase {
  readonly mode: Mode;
  readonly casee: Case;
}
