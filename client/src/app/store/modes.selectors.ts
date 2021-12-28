import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ModesState } from './modes.state';
import { find } from '@utils/utils';
import { isBackendActionLoading, maybeBackendActionError } from '@shared/backend-action-state.model';

export const selectModesState = createFeatureSelector<ModesState>('modes');

export const selectModes = createSelector(
  selectModesState,
  modesState => modesState.serverModes);

export const selectInitialLoadLoading = createSelector(
  selectModesState,
  modesState => isBackendActionLoading(modesState.initialLoadState));

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectModesState,
  modesState => isBackendActionLoading(modesState.initialLoadState) || isBackendActionLoading(modesState.destroyState));

export const selectInitialLoadError = createSelector(
  selectModesState,
  modesState => maybeBackendActionError(modesState.initialLoadState));

export const selectSelectedMode = createSelector(
  selectModesState,
  modesState => find(modesState.serverModes, m => m.id === modesState.selectedModeId));

