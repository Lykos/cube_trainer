import { createReducer, on } from '@ngrx/store';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, destroy, destroySuccess, destroyFailure } from '../state/modes.actions';
import { ModesState } from './modes.state';
import { none, some } from '../utils/optional';

const initialModesState: ModesState = {
  serverModes: [],
  initialLoadLoading: false,
  initialLoadError: none,
  createLoading: false,
  createError: none,
  destroyLoading: false,
  destroyError: none,
};

export const modesReducer = createReducer(
  initialModesState,
  on(initialLoad, (modeState) => {
    return { ...modeState, initialLoadLoading: true, initialLoadError: none };
  }),
  on(initialLoadSuccess, (modeState, { modes }) => {
    return { ...modeState, serverModes: modes, initialLoadLoading: false, initialLoadError: none };
  }),
  on(initialLoadFailure, (modeState, { error }) => {
    return { ...modeState, initialLoadLoading: false, initialLoadError: some(error) };
  }),
  on(create, (modeState, { newMode }) => {
    return { ...modeState, createLoading: true, createError: none };
  }),
  on(createSuccess, (modeState, { mode, newMode }) => {
    return { ...modeState, modes: modeState.serverModes.concat([mode]), createLoading: false, createError: none };
  }),
  on(createFailure, (modeState, { error }) => {
    return { ...modeState, createLoading: false, createError: some(error) };
  }),  
  on(destroy, (modeState, { mode }) => {
    return { ...modeState, destroyLoading: true, destroyError: none };
  }),
  on(destroySuccess, (modeState, { mode }) => {
    return { ...modeState, modes: modeState.serverModes.filter(m => m.id !== mode.id), destroyLoading: false, destroyError: none };
  }),
  on(destroyFailure, (modeState, { error }) => {
    return { ...modeState, destroyLoading: false, destroyError: some(error) };
  }),  
)
