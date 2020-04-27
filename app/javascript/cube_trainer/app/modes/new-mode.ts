import { ModeBase } from './mode-base';

export interface NewMode extends ModeBase {
  readonly modeType: string;
  readonly statTypes: string[];
}
