import { TrainingSessionBase } from './training-session-base.model';
import { RawStat } from './raw-stat.model';
import { TrainingCase } from './training-case.model';
import { GeneratorType } from './generator-type.model';
import { Part } from './part.model';

export interface TrainingSession extends TrainingSessionBase {
  readonly memoTimeS?: number;
  readonly id: number;
  readonly trainingCases: readonly TrainingCase[];
  readonly stats: readonly RawStat[];
  readonly buffer?: Part;
  readonly generatorType: GeneratorType;
}
