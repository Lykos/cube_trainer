import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { InputItem } from './input-item';
import { HttpVerb } from '../rails/http-verb';
import { PartialResult } from './partial-result';
import { Mode } from '../modes/mode';
import { ImgSide } from './img-side';
import { Observable } from 'rxjs';
import { QueueCache } from '../utils/queue-cache';
import { environment } from '../../environments/environment';

function constructPath(modeId: number, input?: InputItem) {
  const suffix = input ? `/${input.id}` : '';
  return `/trainer/${modeId}/inputs${suffix}`;
}

function transformedPartialResult(partialResult: PartialResult) {
  return {timeS: partialResult.duration.toSeconds()};
}

// This is intentionally very small.
// Having a big cache size makes the adaptive sampling in the backend worse.
// We just take 2 to get rid of latencies.
const cacheSize = 2;

@Injectable({
  providedIn: 'root',
})
export class TrainerService {
  constructor(private readonly rails: RailsService) {}

  private readonly inputItemsCacheMap = new Map<number, QueueCache<InputItem>>();

  inputImgSrc(mode: Mode, input: InputItem, imgSide: ImgSide) {
    return `${environment.apiPrefix}${constructPath(mode.id, input)}/image/${imgSide}.jpg`
  }

  private inputItemsCache(modeId: number) {
    const cache = this.inputItemsCacheMap.get(modeId);
    if (cache) {
      return cache;
    }
    const newCache = new QueueCache<InputItem>(cacheSize, (cachedItems: InputItem[]) => this.create(modeId, cachedItems));
    this.inputItemsCacheMap.set(modeId, newCache);
    return newCache;
  }

  nextInputItemWithCache(modeId: number): Observable<InputItem> {
    return this.inputItemsCache(modeId).next();
  }

  prewarmInputItemsCache(modeId: number) {
    this.inputItemsCache(modeId);
  }

  create(modeId: number, cachedItems: InputItem[] = []): Observable<InputItem> {
    const cachedItemIds = cachedItems.map(i => i.id);
    return this.rails.ajax<InputItem>(HttpVerb.Post,constructPath(modeId), {cachedInputIds: cachedItemIds});
  }

  destroy(modeId: number, input: InputItem): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, constructPath(modeId, input), {});
  }

  stop(modeId: number, input: InputItem, partialResult: PartialResult): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Post, constructPath(modeId, input),
				 {partialResult: transformedPartialResult(partialResult)});
  }
}
