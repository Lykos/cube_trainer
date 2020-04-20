import { ModeBase } from './mode-base';

export interface NewMode extends ModeBase {
  readonly statTypes: string[];
}
