import { ShowInputMode } from './show-input-mode';

export interface ModeType {
  readonly name: string;
  readonly showInputModes: ShowInputMode[];
  readonly hasBuffer: boolean;
  readonly defaultCubeSize?: number;
  readonly hasGoalBadness: boolean;
  readonly buffers: string[];
}
