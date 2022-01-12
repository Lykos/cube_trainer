import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { AlgOverride } from './alg-override.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AlgOverridesService {
  constructor(private readonly rails: RailsService) {}

  create(trainingSessionId: number, algOverride: AlgOverride): Observable<void> {
    return this.rails.post<void>(`/training_sessions/${trainingSessionId}/alg_overrides`,
                                 { algOverride: { caseKey: algOverride.trainingCase.caseKey, alg: algOverride.alg } });
  }

  update(trainingSessionId: number, algOverride: AlgOverride): Observable<void> {
    return this.rails.put<void>(`/training_sessions/${trainingSessionId}/alg_overrides`,
                                { algOverride: { caseKey: algOverride.trainingCase.caseKey, alg: algOverride.alg } });
  }
}
