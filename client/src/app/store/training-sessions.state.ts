import { TrainingSession } from '@training/training-session.model';
import { BackendActionState } from '@shared/backend-action-state.model';
import { EntityState } from '@ngrx/entity';

export interface TrainingSessionsState extends EntityState<TrainingSession> {
  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly createAlgOverrideState: BackendActionState;
  readonly updateAlgOverrideState: BackendActionState;
  readonly loadOneState: BackendActionState;

  readonly selectedTrainingSessionId: number;
}
