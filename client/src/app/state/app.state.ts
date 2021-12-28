import { UserState } from './user.state';
import { ModesState } from './modes.state';

export interface AppState {
  user: UserState;
  modes: ModesState;
}
