import { Result } from '@training/result.model';
import { Optional } from '@utils/optional';

export interface ModeResultsState {
  readonly modeId: number;

  // Results that are stored on the backend server.
  // In normal conditions, this contains all results except for the ones that were just created and not sent yet.
  readonly serverResults: readonly Result[];

  readonly initialLoadLoading: boolean;
  readonly initialLoadError: Optional<any>;

  readonly createLoading: boolean;
  readonly createError: Optional<any>;

  readonly destroyLoading: boolean;
  readonly destroyError: Optional<any>;

  readonly markDnfLoading: boolean;
  readonly markDnfError: Optional<any>;
}

export interface ResultsState {
  selectedModeId: number;
  pageSize: number;
  pageIndex: number;
  modeResultsStates: readonly ModeResultsState[];
}
