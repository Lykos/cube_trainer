import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Result } from './result';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class ResultService {
  constructor(private readonly rails: RailsService) {}

  list(modeId: number) {
    return this.rails.ajax<Result[]>(HttpVerb.Get, `/modes/${modeId}/results`, {}).pipe(map(r => {
      console.log(r);
      return r;
    }));
  }
}
