import { ShowInputMode } from './show-input-mode.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { StatType } from './stat-type.model';

export interface ModeType {
  readonly key: string;
  readonly name: string;
  readonly showInputModes: ShowInputMode[];
  readonly hasBoundedInputs: boolean;
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly hasMemoTime: boolean;
  readonly hasSetup: boolean;
  readonly buffers: string[];
  readonly statsTypes: StatType[];
}
