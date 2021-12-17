import { Mode } from '../modes/mode.model';
import { Optional } from '../utils/optional';

export interface ModesState {
  // Modes that are stored on the backend server.
  // If the user is logged in, this contains all modes except for the ones that were just created and not sent yet.
  readonly serverModes: Modes[];

  // Modes that are stored in local storage.
  // If the user is logged out, this contains all modes except for the ones that were just created and not saved yet.
  readonly localStorageModes: Modes[];

  // Modes that are stored in local storage.
  // This contains modes that were just created and not saved yet.
  readonly unsavedModes: Modes[];

  readonly initialLoadFromServerLoading: boolean;
  readonly initialLoadFromServerError: Optional<any>;
}
