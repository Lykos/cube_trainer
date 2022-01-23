import { LetterScheme } from '@training/letter-scheme.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { Optional } from '@utils/optional';

export interface LetterSchemeState {
  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly updateState: BackendActionState;

  readonly letterScheme: Optional<LetterScheme>;
}
