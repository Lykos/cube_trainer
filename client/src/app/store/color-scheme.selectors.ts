import { createSelector, createFeatureSelector } from '@ngrx/store';
import { ColorSchemeState } from './color-scheme.state';
import { isBackendActionLoading } from '@shared/backend-action-state.model';

export const selectColorSchemeState = createFeatureSelector<ColorSchemeState>('colorScheme');

export const selectInitialLoadLoading = createSelector(
  selectColorSchemeState,
  state => isBackendActionLoading(state.initialLoadState),
);

export const selectColorScheme = createSelector(
  selectColorSchemeState,
  state => state.colorScheme,
);
