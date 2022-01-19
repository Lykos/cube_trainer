import { ShowInputMode } from './show-input-mode.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { Part } from './part.model';
import { AlgSet } from './alg-set.model';
import { GeneratorType } from './generator-type.model';

export interface TrainingSessionType {
  readonly id: string;
  readonly name: string;
  readonly showInputModes: readonly ShowInputMode[];
  readonly generatorType: GeneratorType;
  readonly hasBoundedInputs: boolean;
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly hasMemoTime: boolean;
  readonly buffers: readonly Part[];
  readonly algSets: readonly AlgSet[];
}
