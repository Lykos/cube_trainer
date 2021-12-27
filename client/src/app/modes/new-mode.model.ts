import { ModeBase } from './mode-base.model';
import { AlgSet } from './alg-set.model';

export interface NewMode extends ModeBase {
  readonly memoTimeS: number;
  readonly statTypes: string[];
  readonly algSet?: AlgSet;
}
