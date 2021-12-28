import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { AlgOverride } from './alg-override.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AlgOverridesService {
  constructor(private readonly rails: RailsService) {}

  createOrUpdate(modeId: number, algOverride: AlgOverride): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Post, `/modes/${modeId}/alg_overrides/create_or_update`,
                                 { algOverride: { caseKey: algOverride.casee.key, alg: algOverride.alg } });
  }
}
