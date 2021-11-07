import { ModeBase } from './mode-base';

export interface NewMode extends ModeBase {
  readonly memoTimeS: number;
  readonly statTypes: string[];
}
