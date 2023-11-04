import { AlgSource } from './alg-source.model';
import { Case } from './case.model';

// Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
// one twist case, one scramble etc.
// This contains a specific case attached to a training session with a specific solution.
// For the abstract case (independent of its solution), see Case.
export interface TrainingCase {
  readonly casee: Case;
  readonly alg?: string;
  readonly pictureSetup?: string;
  readonly algSource?: AlgSource;
}
