import { TrainingSessionBase } from './training-session-base.model';
import { TrainingCase } from './training-case.model';
import { Duration } from '@utils/duration';

export interface TrainingSession extends TrainingSessionBase {
  readonly memoTime?: Duration;
  readonly id: number;
  readonly numResults: number;
  readonly trainingCases: readonly TrainingCase[];
}
