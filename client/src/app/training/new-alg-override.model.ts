import { TrainingCase } from './training-case.model';

export interface NewAlgOverride {
  readonly trainingCase: TrainingCase;
  readonly alg: string;
}
