import { RailsService } from '@core/rails.service';
import { PartialResult } from './partial-result.model';
import { Injectable } from '@angular/core';
import { HttpVerb } from '@core/http-verb';
import { Result } from './result.model';
import { map } from 'rxjs/operators';
import { Case } from './case.model';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration'
import { fromDateString } from '@utils/instant'

function parseResult(result: any): Result {
  return {
    id: result.id,
    timestamp: fromDateString(result.created_at),
    duration: seconds(result.time_s),
    caseKey: result.case_key,
    caseName: result.case_name,
    numHints: result.num_hints,
    success: result.success,
  };
}

function createResult(casee: Case, partialResult: PartialResult) {
  return {
    caseKey: casee.key,
    timeS: partialResult.duration.toSeconds(),
    numHints: partialResult.numHints,
    success: partialResult.success,
  };
}

@Injectable({
  providedIn: 'root',
})
export class ResultsService {
  constructor(private readonly rails: RailsService) {}

  list(modeId: number, offset?: number, limit?: number): Observable<Result[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, `/modes/${modeId}/results`, {offset, limit}).pipe(
      map(results => results.map(parseResult)));
  }

  destroy(modeId: number, resultId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/modes/${modeId}/results/${resultId}`, {});
  }

  markDnf(modeId: number, resultId: number): Observable<Result> {
    return this.rails.ajax<Result>(HttpVerb.Patch, `/modes/${modeId}/results/${resultId}`,
                                   { result: { success: false } }).pipe(
                                     map(r => { const s = parseResult(r); console.log(s); return s }));
 }

  create(modeId: number, casee: Case, partialResult: PartialResult): Observable<Result> {
    return this.rails.ajax<Result>(HttpVerb.Post, `/modes/${modeId}/results`,
				   {result: createResult(casee, partialResult)}).pipe(
                                     map(parseResult));
  }
}
