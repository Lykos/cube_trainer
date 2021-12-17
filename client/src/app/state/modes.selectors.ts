import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ModesState } from './modes.state';

export const selectModesState = createFeatureSelector<ModesState>('modes');

export const selectModes = createSelector(
  selectModesState,
  modesState => modesState.serverModes);

export const selectInitialLoadOrDestroyLoading = createSelector(
  selectModesState,
  modesState => modesState.initialLoadLoading || modesState.destroyLoading);

export const selectInitialLoadError = createSelector(
  selectModesState,
  modesState => modesState.initialLoadError);
