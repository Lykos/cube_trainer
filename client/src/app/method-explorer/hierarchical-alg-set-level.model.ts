import { UniformAlgSetMode } from '../utils/cube-stats/method-description';
import { PieceWithName } from './piece-with-name.model';
import { FormGroup } from '@angular/forms';

export interface ModeWithName {
  readonly mode: UniformAlgSetMode;
  readonly name: string;
}

export interface HierarchicalAlgSetLevel {
  readonly levelName: string;
  readonly piece: PieceWithName | undefined;
  readonly formGroup: FormGroup;
  readonly hasSublevels: boolean;
  readonly isExpanded: boolean;
  readonly isEnabled: boolean;
  readonly uniformOptions: readonly ModeWithName[];

  getOrCreateSublevels(): readonly HierarchicalAlgSetLevel[];
}
