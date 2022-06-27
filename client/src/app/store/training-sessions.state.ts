import { TrainingSession } from '@training/training-session.model';
import { TrainingSessionSummary } from '@training/training-session-summary.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';

export interface TrainingSessionsState {
  readonly trainingSessions: EntityState<TrainingSession>;
  readonly trainingSessionSummaries: EntityState<TrainingSessionSummary>;
  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly createAlgOverrideState: BackendActionState;
  readonly updateAlgOverrideState: BackendActionState;
  readonly setAlgState: BackendActionState;
  readonly loadOneState: BackendActionState;

  // The selected training session for training.
  readonly selectedTrainingSessionId: number;
}
