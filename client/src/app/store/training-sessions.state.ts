import { TrainingSession } from '@training/training-session.model';
import { BackendActionState } from '@shared/backend-action-state.model';

export interface TrainingSessionsState {
  // TrainingSessions that are stored on the backend server.
  // In normal conditions, this contains all trainingSessions except for the ones that were just created and not sent yet.
  readonly serverTrainingSessions: readonly TrainingSession[];

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly overrideAlgState: BackendActionState;

  readonly selectedTrainingSessionId: number;
}
