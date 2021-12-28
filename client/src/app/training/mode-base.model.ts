import { ShowInputMode } from './show-input-mode.model';
import { Part } from './part.model';
import { ModeType } from './mode-type.model';

export interface ModeBase {
  readonly modeType: ModeType;
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: Part;
  readonly goalBadness?: number;
  readonly memoTimeS?: number;
  readonly cubeSize?: number;
}
