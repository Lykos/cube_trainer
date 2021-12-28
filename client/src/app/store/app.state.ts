import { UserState } from './user.state';
import { ModesState } from './modes.state';
import { ResultsState } from './results.state';

export interface AppState {
  user: UserState;
  modes: ModesState;
  results: ResultsState;
}
