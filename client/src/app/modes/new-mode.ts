import { ModeBase } from './mode-base';

export interface NewMode extends ModeBase {
  readonly modeType: string;
  readonly memoTimeS: number;
  readonly statTypes: string[];
}
