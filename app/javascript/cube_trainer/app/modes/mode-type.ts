import { ShowInputMode } from './show-input-mode';
import { CubeSizeSpec } from './cube-size-spec';

export interface ModeType {
  readonly key: string;
  readonly name: string;
  readonly showInputModes: ShowInputMode[];
  readonly cubeSizeSpec?: CubeSizeSpec;
  readonly hasGoalBadness: boolean;
  readonly buffers: string[];
}
