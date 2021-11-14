import { ModeBase } from './mode-base.model';

export interface NewMode extends ModeBase {
  readonly memoTimeS: number;
  readonly statTypes: string[];
}
