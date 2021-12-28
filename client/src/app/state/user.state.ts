import { User } from '../users/user.model';
import { Optional } from '@utils/optional';

export interface UserState {
  readonly user: Optional<User>;
  readonly initialLoadLoading: boolean;
  readonly initialLoadError: Optional<any>;
  readonly loginLoading: boolean;
  readonly loginError: Optional<any>;
  readonly logoutLoading: boolean;
  readonly logoutError: Optional<any>;
}
