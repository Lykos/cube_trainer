import { TrainingCase } from '@training/training-case.model';
import { AlgOverride } from '@training/alg-override.model';


export function addAlgOverrideToTrainingCase(trainingCase: TrainingCase, algOverride: AlgOverride): TrainingCase {
  if (algOverride.casee.key === trainingCase.casee.key) {
    return { ...trainingCase, alg: algOverride.alg, algSource: { tag: 'overridden', algOverrideId: algOverride.id} };
  } else {
    return trainingCase;
  }
}
