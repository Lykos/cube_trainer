import { ModeBase } from './mode-base.model';
import { Duration } from '../utils/duration';

export interface Mode extends ModeBase {
  readonly memoTime?: Duration;
  readonly id: number;
  readonly numResults: number;
}
