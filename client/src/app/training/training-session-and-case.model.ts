import { TrainingSession } from './training-session.model';
import { TrainingCase } from './training-case.model';

export interface TrainingSessionAndCase {
  readonly trainingSession: TrainingSession;
  readonly trainingCase: TrainingCase;
}
