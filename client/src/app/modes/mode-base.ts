import { ShowInputMode } from './show-input-mode';

export interface ModeBase {
  readonly modeType: string;
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: string;
  readonly goalBadness?: number;
  readonly memoTimeS?: number;
  readonly cubeSize?: number;
}
