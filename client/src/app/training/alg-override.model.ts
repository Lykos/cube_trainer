import { Case } from '../training/case.model';

export interface AlgOverride {
  readonly casee: Case;
  readonly alg: string;
}
