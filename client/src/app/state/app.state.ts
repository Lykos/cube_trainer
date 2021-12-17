import { UserState } from './user.reducer';
import { ModesState } from './modes.reducer';

export interface AppState {
  user: UserState;
  modes: ModesState;
}
