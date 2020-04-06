import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Mode } from './mode';
import { NewMode } from './new-mode';
import { ModeType } from './mode-type';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { ofNull } from '../utils/optional';

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
      defaultCubeSize: ofNull(modeType.default_cube_size),
      hasGoalBadness: modeType.has_goal_badness,
    }
  }

  listTypes(): Observable<ModeType[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, '/mode_types', {}).pipe(map(modeTypes => modeTypes.map(this.parseModeType)));
  }

  list(): Observable<Mode[]> {
    return this.rails.ajax<Mode[]>(HttpVerb.Get, '/modes', {});
  }

  create(mode: NewMode): Observable<Mode> {
    return this.rails.ajax<Mode>(HttpVerb.Post, '/modes', {mode});
  }
}
