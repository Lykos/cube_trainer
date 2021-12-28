import { User } from '@core/user.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { Optional } from '@utils/optional';

export interface UserState {
  readonly user: Optional<User>;
  readonly initialLoadState: BackendActionState;
  readonly loginState: BackendActionState;
  readonly logoutState: BackendActionState;
}
