import { ShowInputMode } from './show-input-mode';

export interface ModeCommon {
  readonly modeType: string;
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: string;
  readonly goalBadness?: number;
  readonly cubeSize?: number;
  readonly statTypes: string[];
}
