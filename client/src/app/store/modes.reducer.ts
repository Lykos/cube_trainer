import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure, overrideAlg, overrideAlgSuccess, overrideAlgFailure, setSelectedModeId } from './modes.actions';
import { ModesState } from './modes.state';
import { backendActionNotStartedState, backendActionLoadingState, backendActionSuccessState, backendActionFailureState } from '@shared/backend-action-state.model';

const initialModesState: ModesState = {
  serverModes: [],
  initialLoadState: backendActionNotStartedState,
  createState: backendActionNotStartedState,
  destroyState: backendActionNotStartedState,
  overrideAlgState: backendActionNotStartedState,
  selectedModeId: 0,
};

export const modesReducer = createReducer(
  initialModesState,
  on(initialLoad, (modeState) => {
    return { ...modeState, initialLoadState: backendActionLoadingState };
  }),
  on(initialLoadSuccess, (modeState, { modes }) => {
    return { ...modeState, serverModes: modes, initialLoadState: backendActionSuccessState };
  }),
  on(initialLoadFailure, (modeState, { error }) => {
    return { ...modeState, initialLoadState: backendActionFailureState(error) };
  }),
  on(create, (modeState, { newMode }) => {
    return { ...modeState, createState: backendActionLoadingState };
  }),
  on(createSuccess, (modeState, { mode, newMode }) => {
    return { ...modeState, serverModes: modeState.serverModes.concat([mode]), createState: backendActionSuccessState };
  }),
  on(createFailure, (modeState, { error }) => {
    return { ...modeState, createError: backendActionFailureState(error) };
  }),  
  on(destroy, (modeState, { mode }) => {
    return { ...modeState, destroyState: backendActionLoadingState };
  }),
  on(destroySuccess, (modeState, { mode }) => {
    return { ...modeState, serverModes: modeState.serverModes.filter(m => m.id !== mode.id), destroyState: backendActionSuccessState };
  }),
  on(destroyFailure, (modeState, { error }) => {
    return { ...modeState, destroyState: backendActionFailureState(error) };
  }),  
  on(overrideAlg, (modeState) => {
    return { ...modeState, overrideAlgState: backendActionLoadingState };
  }),
  on(overrideAlgSuccess, (modeState) => {
    return { ...modeState, overrideAlgState: backendActionSuccessState };
  }),
  on(overrideAlgFailure, (modeState, { error }) => {
    return { ...modeState, overrideAlgState: backendActionFailureState(error) };
  }),  
  on(setSelectedModeId, (modeState, { selectedModeId }) => {
    return { ...modeState, selectedModeId };
  }),
)
