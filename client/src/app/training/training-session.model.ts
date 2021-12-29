import { TrainingSessionBase } from './training-session-base.model';
import { Duration } from '@utils/duration';

export interface TrainingSession extends TrainingSessionBase {
  readonly memoTime?: Duration;
  readonly id: number;
  readonly numResults: number;
}
