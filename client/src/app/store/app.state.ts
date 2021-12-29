import { UserState } from './user.state';
import { TrainingSessionsState } from './training-sessions.state';
import { ResultsState } from './results.state';

export interface AppState {
  user: UserState;
  trainingSessions: TrainingSessionsState;
  results: ResultsState;
}
