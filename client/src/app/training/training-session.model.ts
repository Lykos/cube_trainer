import { TrainingSessionBase } from './training-session-base.model';
import { RawStat } from './raw-stat.model';
import { TrainingCase } from './training-case.model';
import { GeneratorType } from './generator-type.model';
import { Part } from './part.model';

interface CommonTrainingSession extends TrainingSessionBase {
  readonly id: number;
  readonly stats: readonly RawStat[];
  readonly buffer?: Part;
  readonly generatorType: GeneratorType;
}

export interface ScrambleTrainingSession extends CommonTrainingSession {
  readonly generatorType: GeneratorType.Scramble;
  readonly memoTimeS?: number;
}

export interface CaseTrainingSession extends CommonTrainingSession {
  readonly generatorType: GeneratorType.Case;
  readonly trainingCases: readonly TrainingCase[];
}

export type TrainingSession = ScrambleTrainingSession | CaseTrainingSession;
