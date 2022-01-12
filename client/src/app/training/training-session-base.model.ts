import { ShowInputMode } from './show-input-mode.model';
import { Part } from './part.model';
import { TrainingSessionType } from './training-session-type.model';

export interface TrainingSessionBase {
  readonly trainingSessionType: TrainingSessionType;
  readonly name: string;
  readonly known: boolean;
  readonly showInputMode: ShowInputMode;
  readonly buffer?: Part;
  readonly goalBadness?: number;
  readonly cubeSize?: number;
  readonly excludeAlgHoles?: boolean;
  readonly excludeAlglessParts?: boolean;
}
