import { Case } from './case.model';

export interface AlgOverride {
  readonly casee: Case;
  readonly id: number;
  readonly alg: string;
}
