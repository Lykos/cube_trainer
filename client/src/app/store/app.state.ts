import { UserState } from './user.state';
import { TrainingSessionsState } from './training-sessions.state';
import { TrainerState } from './trainer.state';

export interface AppState {
  user: UserState;
  trainingSessions: TrainingSessionsState;
  trainer: TrainerState;
}
