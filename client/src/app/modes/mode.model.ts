import { ModeBase } from './mode-base.model';
import { ModeType } from './mode-type.model';
import { Duration } from '../utils/duration';

export interface Mode extends ModeBase {
  readonly modeType: ModeType;
  readonly memoTime?: Duration;
  readonly id: number;
  readonly numResults: number;
}
