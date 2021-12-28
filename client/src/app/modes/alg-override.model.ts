import { Case } from '../trainer/case.model';

export interface AlgOverride {
  readonly casee: Case;
  readonly alg: string;
}
