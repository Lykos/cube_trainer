import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Mode } from './mode';
import { CubeSizeSpec } from './cube-size-spec';
import { NewMode } from './new-mode';
import { ModeType } from './mode-type';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';

function parseCubeSizeSpec(rawCubeSizeSpec: any): CubeSizeSpec {
  return {
    default: rawCubeSizeSpec.default,
    min: rawCubeSizeSpec.min,
    max: rawCubeSizeSpec.max,
    oddAllowed: rawCubeSizeSpec.odd_allowed,
    evenAllowed: rawCubeSizeSpec.even_allowed,
  };
}

function parseModeType(rawModeType: any): ModeType {
  const cubeSizeSpec = rawModeType.cube_size_spec ? parseCubeSizeSpec(rawModeType.cube_size_spec) : undefined;
  return {
    key: rawModeType.key,
    name: rawModeType.name,
    showInputModes: rawModeType.show_input_modes,
    hasBoundedInputs: rawModeType.has_bounded_inputs,
    cubeSizeSpec,
    hasGoalBadness: rawModeType.has_goal_badness,
    hasMemoTime: rawModeType.has_memo_time,
    buffers: rawModeType.buffers,
    statsTypes: rawModeType.stats_types,
  };
}

function parseMode(rawMode: any): Mode {
  return {
    id: rawMode.id,
    modeType: rawMode.mode_type,
    name: rawMode.name,
    known: rawMode.known,
    showInputMode: rawMode.show_input_mode,
    buffer: rawMode.buffer,
    goalBadness: rawMode.goal_badness,
    memoTime: rawMode.memo_time,
    cubeSize: rawMode.cube_size,
    numResults: rawMode.num_results,
  };
}

@Injectable({
  providedIn: 'root',
})
export class ModesService {
  constructor(private readonly rails: RailsService) {}

  isModeNameTaken(modeName: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/mode_name_exists_for_user', {modeName});
  }

  listTypes(): Observable<ModeType[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, '/mode_types', {}).pipe(
      map(modeTypes => modeTypes.map(parseModeType)));
  }

  list(): Observable<Mode[]> {
    return this.rails.ajax<Mode[]>(HttpVerb.Get, '/modes', {}).pipe(
      map(modeTypes => modeTypes.map(parseMode)));
  }

  show(modeId: number): Observable<Mode> {
    return this.rails.ajax<Mode>(HttpVerb.Get, `/modes/${modeId}`, {}).pipe(map(parseMode));
  }

  destroy(modeId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/modes/${modeId}`, {});
  }

  create(mode: NewMode): Observable<Mode> {
    return this.rails.ajax<Mode>(HttpVerb.Post, '/modes', {mode});
  }
}
