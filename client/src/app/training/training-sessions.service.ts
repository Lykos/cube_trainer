import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { TrainingSession } from './training-session.model';
import { TrainingSessionSummary } from './training-session-summary.model';
import { NewTrainingSession } from './new-training-session.model';
import { TrainingSessionType } from './training-session-type.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class TrainingSessionsService {
  constructor(private readonly rails: RailsService) {}

  isTrainingSessionNameTaken(trainingSessionName: string): Observable<boolean> {
    return this.rails.get<boolean>('/training_session_name_exists_for_user', {trainingSessionName});
  }

  listTypes(): Observable<TrainingSessionType[]> {
    return this.rails.get<TrainingSessionType[]>('/training_session_types', {});
  }

  list(): Observable<TrainingSessionSummary[]> {
    return this.rails.get<TrainingSessionSummary[]>('/training_sessions', {});
  }

  show(trainingSessionId: number): Observable<TrainingSession> {
    return this.rails.get<TrainingSession>(`/training_sessions/${trainingSessionId}`, {});
  }

  destroy(trainingSessionId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}`, {});
  }

  create(trainingSession: NewTrainingSession): Observable<TrainingSessionSummary> {
    return this.rails.post<TrainingSessionSummary>('/training_sessions', {trainingSession});
  }
}
