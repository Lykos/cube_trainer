import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Mode } from './mode';
import { NewMode } from './new-mode';
import { ModeType } from './mode-type';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ModeService {
  constructor(private readonly rails: RailsService) {}

  parseModeType(modeType: any): ModeType {
    return {
      name: modeType.name,
      showInputModes: modeType.show_input_modes,
      hasBuffer: modeType.has_buffer,
      defaultCubeSize: modeType.default_cube_size,
      hasGoalBadness: modeType.has_goal_badness,
      buffers: modeType.buffers,
    }
  }

  parseMode(mode: any): Mode {
    return {
      id: mode.id,
      modeType: mode.mode_type,
      name: mode.name,
      known: mode.known,
      showInputMode: mode.show_input_mode,
      buffer: mode.buffer,
      goalBadness: mode.goalBadness,
      cubeSize: mode.cubeSize,
      numResults: mode.num_results,
    }
  }

  listTypes(): Observable<ModeType[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, '/mode_types', {}).pipe(
      map(modeTypes => modeTypes.map(this.parseModeType)));
  }

  list(): Observable<Mode[]> {
    return this.rails.ajax<Mode[]>(HttpVerb.Get, '/modes', {}).pipe(
      map(modeTypes => modeTypes.map(this.parseMode)));
  }

  show(modeId: number): Observable<Mode> {
    return this.rails.ajax<Mode>(HttpVerb.Get, `/modes/${modeId}`, {}).pipe(map(this.parseMode));
  }

  create(mode: NewMode): Observable<Mode> {
    return this.rails.ajax<Mode>(HttpVerb.Post, '/modes', {mode});
  }
}
