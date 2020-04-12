import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { InputItem } from './input_item';
import { HttpVerb } from '../rails/http_verb';
import { PartialResult } from './partial-result';
import { Mode } from '../mode/mode';
import { ImgSide } from './img-side';

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  inputImgSrc(mode: Mode, input: InputItem, imgSide: ImgSide) {
    return `${this.constructPath(mode.id, input)}/image/${imgSide}.jpg`
  }

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

  stop(modeId: number, input: InputItem, partialResult: PartialResult) {
    return this.rails.ajax<void>(HttpVerb.Post, this.constructPath(modeId, input), {partialResult: this.transformedPartialResult(partialResult)});
  }

  transformedPartialResult(partialResult: PartialResult) {
    return {timeS: partialResult.duration.toSeconds()};
  }
}
