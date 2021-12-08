import { User } from '../users/user.model';
import { Optional } from '../utils/optional';

export interface UserState {
  readonly user: Optional<User>;
  readonly loading: boolean;
  readonly error: Optional<any>;
}
