import { TrainingSessionBase } from './training-session-base.model';
import { TrainingCase } from './training-case.model';

export interface TrainingSession extends TrainingSessionBase {
  readonly memoTimeS?: number;
  readonly id: number;
  readonly numResults: number;
  readonly trainingCases: readonly TrainingCase[];
}
