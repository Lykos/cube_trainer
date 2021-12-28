import { Result } from '@training/result.model';
import { BackendActionState } from '@shared/backend-action-state.model';

export interface ModeResultsState {
  readonly modeId: number;

  // Results that are stored on the backend server.
  // In normal conditions, this contains all results except for the ones that were just created and not sent yet.
  readonly serverResults: readonly Result[];

  readonly initialLoadState: BackendActionState;
  readonly createState: BackendActionState;
  readonly destroyState: BackendActionState;
  readonly markDnfState: BackendActionState;
}

export interface ResultsState {
  selectedModeId: number;
  pageSize: number;
  pageIndex: number;
  modeResultsStates: readonly ModeResultsState[];
}
