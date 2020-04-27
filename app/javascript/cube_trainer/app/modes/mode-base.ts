import { ShowInputMode } from './show-input-mode';

export interface ModeBase {
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: string;
  readonly goalBadness?: number;
  readonly cubeSize?: number;
}
