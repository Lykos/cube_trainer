import { createReducer, on } from '@ngrx/store';

import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, update, updateSuccess, updateFailure } from './letter-scheme.actions';
import { LetterSchemeState } from './letter-scheme.state';
import { none, some } from '@utils/optional';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

export const initialLetterSchemeState: LetterSchemeState = {
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  updateState: backendActionNotStartedState,
  letterScheme: none,
};

export const letterSchemeReducer = createReducer(
  initialLetterSchemeState,
  on(initialLoad, (letterSchemeState) => { return { ...letterSchemeState, createState: backendActionLoadingState }; }),
  on(initialLoadSuccess, (letterSchemeState, { letterScheme }) => { return { ...letterSchemeState, letterScheme: some(letterScheme), createState: backendActionSuccessState }; }),
  on(initialLoadFailure, (letterSchemeState, { error }) => { return { ...letterSchemeState, createState: backendActionFailureState(error) }; }),
  on(create, (letterSchemeState) => { return { ...letterSchemeState, createState: backendActionLoadingState }; }),
  on(createSuccess, (letterSchemeState, { letterScheme }) => { return { ...letterSchemeState, letterScheme: some(letterScheme), createState: backendActionSuccessState }; }),
  on(createFailure, (letterSchemeState, { error }) => { return { ...letterSchemeState, createState: backendActionFailureState(error) }; }),
  on(update, (letterSchemeState) => { return { ...letterSchemeState, updateState: backendActionLoadingState }; }),
  on(updateSuccess, (letterSchemeState, { letterScheme }) => { return { ...letterSchemeState, letterScheme: some(letterScheme), updateState: backendActionSuccessState }; }),
  on(updateFailure, (letterSchemeState, { error }) => { return { ...letterSchemeState, updateState: backendActionFailureState(error) }; }),
);
