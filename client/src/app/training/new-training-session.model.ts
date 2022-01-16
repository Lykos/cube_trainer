import { TrainingSessionBase } from './training-session-base.model';

export interface NewTrainingSession extends TrainingSessionBase {
  readonly memoTimeS: number;
  readonly statTypes: string[];
  readonly algSetId?: number;
  readonly trainingSessionType: string;
  readonly buffer: string;
}
