import { createReducer, on } from '@ngrx/store';

import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, update, updateSuccess, updateFailure } from './color-scheme.actions';
import { ColorSchemeState } from './color-scheme.state';
import { none, some } from '@utils/optional';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

export const initialColorSchemeState: ColorSchemeState = {
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  updateState: backendActionNotStartedState,
  colorScheme: none,
};

export const colorSchemeReducer = createReducer(
  initialColorSchemeState,
  on(initialLoad, (colorSchemeState) => { return { ...colorSchemeState, createState: backendActionLoadingState }; }),
  on(initialLoadSuccess, (colorSchemeState, { colorScheme }) => { return { ...colorSchemeState, colorScheme: some(colorScheme), createState: backendActionSuccessState }; }),
  on(initialLoadFailure, (colorSchemeState, { error }) => { return { ...colorSchemeState, createState: backendActionFailureState(error) }; }),
  on(create, (colorSchemeState) => { return { ...colorSchemeState, createState: backendActionLoadingState }; }),
  on(createSuccess, (colorSchemeState, { colorScheme }) => { return { ...colorSchemeState, colorScheme: some(colorScheme), createState: backendActionSuccessState }; }),
  on(createFailure, (colorSchemeState, { error }) => { return { ...colorSchemeState, createState: backendActionFailureState(error) }; }),
  on(update, (colorSchemeState) => { return { ...colorSchemeState, updateState: backendActionLoadingState }; }),
  on(updateSuccess, (colorSchemeState, { colorScheme }) => { return { ...colorSchemeState, colorScheme: some(colorScheme), updateState: backendActionSuccessState }; }),
  on(updateFailure, (colorSchemeState, { error }) => { return { ...colorSchemeState, updateState: backendActionFailureState(error) }; }),
);
