import { TrainingSessionBase } from './training-session-base.model';
import { AlgSet } from './alg-set.model';

export interface NewTrainingSession extends TrainingSessionBase {
  readonly memoTimeS: number;
  readonly statTypes: string[];
  readonly algSet?: AlgSet;
}
