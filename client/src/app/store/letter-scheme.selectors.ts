import { createSelector, createFeatureSelector } from '@ngrx/store';
import { LetterSchemeState } from './letter-scheme.state';
import { isBackendActionLoading } from '@shared/backend-action-state.model';

export const selectLetterSchemeState = createFeatureSelector<LetterSchemeState>('letterScheme');

export const selectInitialLoadLoading = createSelector(
  selectLetterSchemeState,
  state => isBackendActionLoading(state.initialLoadState),
);

export const selectLetterScheme = createSelector(
  selectLetterSchemeState,
  state => state.letterScheme,
);
