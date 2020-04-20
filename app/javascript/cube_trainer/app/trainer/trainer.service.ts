import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { InputItem } from './input-item';
import { HttpVerb } from '../rails/http_verb';
import { PartialResult } from './partial-result';
import { Mode } from '../modes/mode';
import { ImgSide } from './img-side';
import { Observable } from 'rxjs';

function constructPath(modeId: number, input?: InputItem) {
  const suffix = input ? `/${input.id}` : '';
  return `/trainer/${modeId}/inputs${suffix}`;
}

function transformedPartialResult(partialResult: PartialResult) {
  return {timeS: partialResult.duration.toSeconds()};
}

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  inputImgSrc(mode: Mode, input: InputItem, imgSide: ImgSide) {
    return `${constructPath(mode.id, input)}/image/${imgSide}.jpg`
  }

  create(modeId: number): Observable<InputItem> {
    return this.rails.ajax<InputItem>(HttpVerb.Post, constructPath(modeId), {});
  }

  destroy(modeId: number, input: InputItem): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, constructPath(modeId, input), {});
  }

  stop(modeId: number, input: InputItem, partialResult: PartialResult): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Post, constructPath(modeId, input),
				 {partialResult: transformedPartialResult(partialResult)});
  }
}
