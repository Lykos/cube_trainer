import { Duration } from '../../../utils/duration';
import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { InputItem } from './input_item';
import { HttpVerb } from '../rails/http_verb';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  path(modeId: number, method: string) {
    return `/training/${modeId}/${method}`;
  }

  nextInput(modeId: number) {
    return this.rails.ajax<InputItem>(HttpVerb.Post, this.path(modeId, 'next_input'), {});
  }

  dropInput(modeId: number, input: InputItem) {
    return this.rails.ajax<void>(HttpVerb.Post, this.path(modeId, 'drop_input'), {id: input.id});
  }

  stop(modeId: number, input: InputItem, duration: Duration) {
    return this.rails.ajax<void>(HttpVerb.Post, this.path(modeId, 'stop'), {id: input.id, timeS: duration.toSeconds()});
  }
}
