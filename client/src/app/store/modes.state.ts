import { Mode } from '@training/mode.model';
import { BackendActionState } from '@shared/backend-action-state.model';

export interface ModesState {
  // Modes that are stored on the backend server.
  // In normal conditions, this contains all modes except for the ones that were just created and not sent yet.
  readonly serverModes: readonly Mode[];

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly overrideAlgState: BackendActionState;

  readonly selectedModeId: number;
}
