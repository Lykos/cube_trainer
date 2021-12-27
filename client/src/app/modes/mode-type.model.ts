import { ShowInputMode } from './show-input-mode.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { StatType } from './stat-type.model';
import { Part } from '../users/part.model';
import { AlgSet } from './alg-set.model';

export interface ModeType {
  readonly key: string;
  readonly name: string;
  readonly showInputModes: ShowInputMode[];
  readonly hasBoundedInputs: boolean;
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly hasMemoTime: boolean;
  readonly hasSetup: boolean;
  readonly buffers: Part[];
  readonly statsTypes: StatType[];
  readonly algSets: AlgSet[];
}
