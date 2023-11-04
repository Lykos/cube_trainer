import { ShowInputMode } from './show-input-mode.model';

export interface TrainingSessionBase {
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly goalBadness?: number;
  readonly cubeSize?: number;
}
