import { AlgSource } from './alg-source.model';

// Represents case that we train to get better on, e.g. one 3-cycle, one parity case,
// one twist case, one scramble etc.
// This contains a specific case attached to a training session with a specific solution.
// For the abstract case (independent of its solution), we use the key.
export interface TrainingCase {
  readonly caseKey: string;
  readonly caseName: string;
  readonly alg?: string;
  readonly setup?: string;
  readonly algSource?: AlgSource;
}
