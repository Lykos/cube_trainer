import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { TrainingSession } from './training-session.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { NewTrainingSession } from './new-training-session.model';
import { TrainingSessionType } from './training-session-type.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration';

function parseCubeSizeSpec(rawCubeSizeSpec: any): CubeSizeSpec {
  return {
    default: rawCubeSizeSpec.default,
    min: rawCubeSizeSpec.min,
    max: rawCubeSizeSpec.max,
    oddAllowed: rawCubeSizeSpec.odd_allowed,
    evenAllowed: rawCubeSizeSpec.even_allowed,
  };
}

function parseTrainingSessionType(rawTrainingSessionType: any): TrainingSessionType {
  const cubeSizeSpec = rawTrainingSessionType.cube_size_spec ? parseCubeSizeSpec(rawTrainingSessionType.cube_size_spec) : undefined;
  return {
    key: rawTrainingSessionType.key,
    name: rawTrainingSessionType.name,
    showInputModes: rawTrainingSessionType.show_input_modes,
    hasBoundedInputs: rawTrainingSessionType.has_bounded_inputs,
    cubeSizeSpec,
    hasGoalBadness: rawTrainingSessionType.has_goal_badness,
    hasMemoTime: rawTrainingSessionType.has_memo_time,
    hasSetup: rawTrainingSessionType.has_setup,
    buffers: rawTrainingSessionType.buffers,
    statsTypes: rawTrainingSessionType.stats_types,
    algSets: rawTrainingSessionType.alg_sets,
  };
}

function parseTrainingSession(rawTrainingSession: any): TrainingSession {
  return {
    id: rawTrainingSession.id,
    trainingSessionType: parseTrainingSessionType(rawTrainingSession.training_session_type),
    name: rawTrainingSession.name,
    known: rawTrainingSession.known,
    showInputMode: rawTrainingSession.show_input_mode,
    buffer: rawTrainingSession.buffer,
    goalBadness: rawTrainingSession.goal_badness,
    memoTime: rawTrainingSession.memo_time_s ? seconds(rawTrainingSession.memo_time_s) : undefined,
    cubeSize: rawTrainingSession.cube_size,
    numResults: rawTrainingSession.num_results,
  };
}

@Injectable({
  providedIn: 'root',
})
export class TrainingSessionsService {
  constructor(private readonly rails: RailsService) {}

  isTrainingSessionNameTaken(trainingSessionName: string): Observable<boolean> {
    return this.rails.get<boolean>('/training_session_name_exists_for_user', {trainingSessionName});
  }

  listTypes(): Observable<TrainingSessionType[]> {
    return this.rails.get<any[]>('/training_session_types', {}).pipe(
      map(trainingSessionTypes => trainingSessionTypes.map(parseTrainingSessionType)));
  }

  list(): Observable<TrainingSession[]> {
    return this.rails.get<TrainingSession[]>('/training_sessions', {}).pipe(
      map(trainingSessions => trainingSessions.map(parseTrainingSession)));
  }

  show(trainingSessionId: number): Observable<TrainingSession> {
    return this.rails.get<TrainingSession>(`/training_sessions/${trainingSessionId}`, {}).pipe(map(parseTrainingSession));
  }

  destroy(trainingSessionId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}`, {});
  }

  create(trainingSession: NewTrainingSession): Observable<TrainingSession> {
    return this.rails.post<TrainingSession>('/training_sessions', {trainingSession}).pipe(map(parseTrainingSession));
  }
}
