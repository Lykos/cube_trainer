import { ShowInputMode } from './show-input-mode';
import { CubeSizeSpec } from './cube-size-spec';
import { StatType } from './stat-type';

export interface ModeType {
  readonly key: string;
  readonly name: string;
  readonly showInputModes: ShowInputMode[];
  readonly hasBoundedInputs: bool;
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly buffers: string[];
  readonly statsTypes: StatType[];
}
