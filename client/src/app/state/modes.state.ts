import { Mode } from '../modes/mode.model';
import { Optional } from '../utils/optional';

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
}
