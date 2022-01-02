import { TrainingCase } from './training-case.model';

export interface AlgOverride {
  readonly trainingCase: TrainingCase;
  readonly alg: string;
}
