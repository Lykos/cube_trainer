import { CaseTrainingSession, ScrambleTrainingSession } from './training-session.model';
import { TrainingCase } from './training-case.model';
import { GeneratorType } from './generator-type.model';
import { SamplingState } from '@utils/sampling';

interface CaseTrainingSessionAndSamplingState {
  readonly generatorType: GeneratorType.Case;
  readonly trainingSession: CaseTrainingSession;
  readonly samplingState: SamplingState<TrainingCase>;
};

interface ScrambleTrainingSessionAndNoSamplingState {
  readonly generatorType: GeneratorType.Scramble;
  readonly trainingSession: ScrambleTrainingSession;
};

export type TrainingSessionAndMaybeSamplingState = CaseTrainingSessionAndSamplingState | ScrambleTrainingSessionAndNoSamplingState;
