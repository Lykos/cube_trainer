import { TrainingSession } from './training-session.model';
import { ScrambleOrSample } from './scramble-or-sample.model';

export interface TrainingSessionAndScrambleOrSample {
  readonly trainingSession: TrainingSession;
  readonly scrambleOrSample: ScrambleOrSample;
}
