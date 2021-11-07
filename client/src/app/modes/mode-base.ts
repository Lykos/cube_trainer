import { ShowInputMode } from './show-input-mode';
import { Duration } from '../utils/duration';

export interface ModeBase {
  readonly modeType: string;
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: string;
  readonly goalBadness?: number;
  readonly memoTime?: Duration;
  readonly cubeSize?: number;
}
