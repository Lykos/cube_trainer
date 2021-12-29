import { TrainingSession } from './training-session.model';
import { Case } from './case.model';

export interface TrainingSessionAndCase {
  readonly trainingSession: TrainingSession;
  readonly casee: Case;
}
