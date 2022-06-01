import { TrainingCase } from '@training/training-case.model';
import { AlgOverride } from '@training/alg-override.model';


export function addAlgOverrideToTrainingCase(trainingCase: TrainingCase, algOverride: AlgOverride): TrainingCase {
  return { ...trainingCase, alg: algOverride.alg, algSource: { tag: 'overridden', algOverrideId: algOverride.id} };
}
