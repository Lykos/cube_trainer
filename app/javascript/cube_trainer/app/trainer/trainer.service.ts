import { Duration } from '../utils/duration';
import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { InputItem } from './input_item';
import { HttpVerb } from '../rails/http_verb';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  constructPath(modeId: number, input?: InputItem) {
    const suffix = input ? `/${input.id}` : '';
    return `/trainer/${modeId}/inputs${suffix}`;
  }

  create(modeId: number) {
    return this.rails.ajax<InputItem>(HttpVerb.Post, this.constructPath(modeId), {});
  }

  destroy(modeId: number, input: InputItem) {
    return this.rails.ajax<void>(HttpVerb.Delete, this.constructPath(modeId, input), {});
  }

  stop(modeId: number, input: InputItem, duration: Duration) {
    return this.rails.ajax<void>(HttpVerb.Post, this.constructPath(modeId, input), {timeS: duration.toSeconds()});
  }
}
