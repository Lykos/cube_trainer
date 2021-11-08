import { ShowInputMode } from './show-input-mode.model';

export interface ModeBase {
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: string;
  readonly goalBadness?: number;
  readonly memoTimeS?: number;
  readonly cubeSize?: number;
}
