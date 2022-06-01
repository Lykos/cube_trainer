import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { NewAlgOverride } from './new-alg-override.model';
import { AlgOverride } from './alg-override.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AlgOverridesService {
  constructor(private readonly rails: RailsService) {}

  create(trainingSessionId: number, algOverride: NewAlgOverride): Observable<AlgOverride> {
    return this.rails.post<AlgOverride>(`/training_sessions/${trainingSessionId}/alg_overrides`,
					{ algOverride: { caseKey: algOverride.trainingCase.casee.key, alg: algOverride.alg } });
  }

  update(trainingSessionId: number, algOverrideId: number, alg: string): Observable<AlgOverride> {
    return this.rails.put<AlgOverride>(`/training_sessions/${trainingSessionId}/alg_overrides/${algOverrideId}`,
                                       { algOverride: { alg } });
  }
}
