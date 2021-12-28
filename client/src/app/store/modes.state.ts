import { Mode } from '../training/mode.model';
import { Optional } from '@utils/optional';
import { BackendActionError } from '@shared/backend-action-error.model';

export interface ModesState {
  // Modes that are stored on the backend server.
  // In normal conditions, this contains all modes except for the ones that were just created and not sent yet.
  readonly serverModes: readonly Mode[];

  readonly initialLoadLoading: boolean;
  readonly initialLoadError: Optional<any>;

  readonly createLoading: boolean;
  readonly createError: Optional<any>;

  readonly destroyLoading: boolean;
  readonly destroyError: Optional<any>;

  readonly overrideAlgLoading: boolean;
  readonly overrideAlgError: Optional<BackendActionError>;

  readonly selectedModeId: number;
}
