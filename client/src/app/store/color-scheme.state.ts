import { ColorScheme } from '@training/color-scheme.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { Optional } from '@utils/optional';

export interface ColorSchemeState {
  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly updateState: BackendActionState;

  readonly colorScheme: Optional<ColorScheme>;
}
