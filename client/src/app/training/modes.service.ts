import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Mode } from './mode.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { NewMode } from './new-mode.model';
import { ModeType } from './mode-type.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration';

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
    hasSetup: rawModeType.has_setup,
    buffers: rawModeType.buffers,
    statsTypes: rawModeType.stats_types,
    algSets: rawModeType.alg_sets,
  };
}

function parseMode(rawMode: any): Mode {
  return {
    id: rawMode.id,
    modeType: parseModeType(rawMode.mode_type),
    name: rawMode.name,
    known: rawMode.known,
    showInputMode: rawMode.show_input_mode,
    buffer: rawMode.buffer,
    goalBadness: rawMode.goal_badness,
    memoTime: rawMode.memo_time_s ? seconds(rawMode.memo_time_s) : undefined,
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
    return this.rails.get<boolean>('/mode_name_exists_for_user', {modeName});
  }

  listTypes(): Observable<ModeType[]> {
    return this.rails.get<any[]>('/mode_types', {}).pipe(
      map(modeTypes => modeTypes.map(parseModeType)));
  }

  list(): Observable<Mode[]> {
    return this.rails.get<Mode[]>('/modes', {}).pipe(
      map(modes => modes.map(parseMode)));
  }

  show(modeId: number): Observable<Mode> {
    return this.rails.get<Mode>(`/modes/${modeId}`, {}).pipe(map(parseMode));
  }

  destroy(modeId: number): Observable<void> {
    return this.rails.delete<void>(`/modes/${modeId}`, {});
  }

  create(mode: NewMode): Observable<Mode> {
    return this.rails.post<Mode>('/modes', {mode}).pipe(map(parseMode));
  }
}
