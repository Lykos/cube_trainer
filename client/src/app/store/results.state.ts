import { Result } from '@training/result.model';
import { BackendActionState } from '@shared/backend-action-state.model';

export interface TrainingSessionResultsState {
  readonly trainingSessionId: number;

  // Results that are stored on the backend server.
  // In normal conditions, this contains all results except for the ones that were just created and not sent yet.
  readonly serverResults: readonly Result[];

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
}

export interface ResultsState {
  selectedTrainingSessionId: number;
  pageSize: number;
  pageIndex: number;
  trainingSessionResultsStates: readonly TrainingSessionResultsState[];
}
