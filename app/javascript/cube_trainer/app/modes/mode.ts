import { ModeBase } from './mode-base';
import { ModeType } from './mode-type';

export interface Mode extends ModeBase {
  readonly id: number;
  readonly numResults: number;
  readonly modeType: ModeType;
}
