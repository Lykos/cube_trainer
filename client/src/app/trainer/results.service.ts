import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Result } from './result.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '../utils/duration'
import { fromDateString } from '../utils/instant'

function parseResult(result: any): Result {
  return {
    id: result.id,
    timestamp: fromDateString(result.created_at),
    duration: seconds(result.time_s),
    inputRepresentation: result.input_representation,
    numHints: result.num_hints,
    success: result.success,
  };
}

@Injectable({
  providedIn: 'root',
})
export class ResultsService {
  constructor(private readonly rails: RailsService) {}

  list(modeId: number, offset: number, limit: number): Observable<Result[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, `/modes/${modeId}/results`, {offset, limit}).pipe(
      map(results => results.map(parseResult)));
  }

  destroy(modeId: number, resultId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/modes/${modeId}/results/${resultId}`, {});
  }

  markDnf(modeId: number, resultId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Patch, `/modes/${modeId}/results/${resultId}`, {result: {success: false}});
 }
}
