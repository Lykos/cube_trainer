import { ModeBase } from './mode-base';
import { ModeType } from './mode-type';
import { Duration } from '../utils/duration';

export interface Mode extends ModeBase {
  readonly modeType: ModeType;
  readonly memoTime?: Duration;
  readonly id: number;
  readonly numResults: number;
}
