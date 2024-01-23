import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { Result } from './result.model';
import { NewResult } from './new-result.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ResultsService {
  constructor(private readonly rails: RailsService) {}

  list(trainingSessionId: number, offset?: number, limit?: number): Observable<Result[]> {
    return this.rails.get<Result[]>(`/training_sessions/${trainingSessionId}/results`, { offset, limit });
  }

  destroy(trainingSessionId: number, resultId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/results/${resultId}`, {});
  }

  markDnf(trainingSessionId: number, resultId: number): Observable<Result> {
    return this.rails.patch<Result>(`/training_sessions/${trainingSessionId}/results/${resultId}`,
                                    { result: { success: false } });
  }

  markHint(trainingSessionId: number, resultId: number): Observable<Result> {
    return this.rails.patch<Result>(`/training_sessions/${trainingSessionId}/results/${resultId}`,
                                    { result: { numHints: 1 } });
  }

  create(trainingSessionId: number, newResult: NewResult): Observable<Result> {
    const result = {
      timeS: newResult.timeS,
      caseKey: newResult.casee.key,
      success: newResult.success,
      numHints: newResult.numHints,
    };
    return this.rails.post<Result>(`/training_sessions/${trainingSessionId}/results`,
				   { result });
  }
}
