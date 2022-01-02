import { ShowInputMode } from './show-input-mode.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { StatType } from './stat-type.model';
import { Part } from './part.model';
import { AlgSet } from './alg-set.model';

export interface TrainingSessionType {
  readonly key: string;
  readonly name: string;
  readonly showInputModes: readonly ShowInputMode[];
  readonly hasBoundedInputs: boolean;
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly hasMemoTime: boolean;
  readonly hasSetup: boolean;
  readonly buffers: readonly Part[];
  readonly statsTypes: readonly StatType[];
  readonly algSets: readonly AlgSet[];
}
