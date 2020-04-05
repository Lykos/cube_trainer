import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Result } from './result';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '../utils/duration'
import { fromDateString } from '../utils/instant'

@Injectable({
  providedIn: 'root',
})
export class ResultService {
  constructor(private readonly rails: RailsService) {}

  parseResult(result: any) {
    return {
      id: result.id,
      timestamp: fromDateString(result.created_at),
      duration: seconds(result.time_s),
      inputRepresentation: result.input_representation,
    };
  }

  list(modeId: number, offset: number, limit: number): Observable<Result[]> {
    return this.rails.ajax<any>(HttpVerb.Get, `/modes/${modeId}/results`, {offset, limit}).pipe(map(results => {
      
      const r = results.map(this.parseResult);
      console.log(r);
      return r;
    }));
  }
}
