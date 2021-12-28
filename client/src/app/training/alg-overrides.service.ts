import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { AlgOverride } from './alg-override.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AlgOverridesService {
  constructor(private readonly rails: RailsService) {}

  createOrUpdate(modeId: number, algOverride: AlgOverride): Observable<void> {
    return this.rails.post<void>(`/modes/${modeId}/alg_overrides/create_or_update`,
                                 { algOverride: { caseKey: algOverride.casee.key, alg: algOverride.alg } });
  }
}
