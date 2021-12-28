import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ModesState } from './modes.state';
import { find } from '@utils/utils';

export const selectModesState = createFeatureSelector<ModesState>('modes');

export const selectModes = createSelector(
  selectModesState,
  modesState => modesState.serverModes);

export const selectInitialLoadLoading = createSelector(
  selectModesState,
  modesState => modesState.initialLoadLoading);

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectModesState,
  modesState => modesState.initialLoadLoading || modesState.destroyLoading);

export const selectInitialLoadError = createSelector(
  selectModesState,
  modesState => modesState.initialLoadError);

export const selectSelectedMode = createSelector(
  selectModesState,
  modesState => find(modesState.serverModes, m => m.id === modesState.selectedModeId));

