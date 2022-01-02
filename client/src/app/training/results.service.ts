import { RailsService } from '@core/rails.service';
import { PartialResult } from './partial-result.model';
import { Injectable } from '@angular/core';
import { Result } from './result.model';
import { map } from 'rxjs/operators';
import { TrainingCase } from './training-case.model';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration'
import { fromDateString } from '@utils/instant'
import { FieldMissingError, FieldTypeError } from '@shared/rails-parse-error';

interface RawResult {
  readonly id?: unknown;
  readonly createdAt?: unknown;
  readonly timeS?: unknown;
  readonly caseKey?: unknown;
  readonly caseName?: unknown;
  readonly numHints?: unknown;
  readonly success?: unknown;
}

function parseResult(result: RawResult): Result {
  if (result.id === undefined) {
    throw new FieldMissingError('id', 'result', result);
  }
  if (typeof result.id !== 'number') {
    throw new FieldTypeError('id', 'number', 'result', result);
  }
  if (result.createdAt === undefined) {
    throw new FieldMissingError('createdAt', 'result', result);
  }
  if (typeof result.createdAt !== 'string') {
    throw new FieldTypeError('createdAt', 'string', 'result', result);
  }
  if (result.caseKey === undefined) {
    throw new FieldMissingError('caseKey', 'result', result);
  }
  if (typeof result.caseKey !== 'string') {
    throw new FieldTypeError('caseKey', 'string', 'result', result);
  }
  if (result.caseName === undefined) {
    throw new FieldMissingError('caseName', 'result', result);
  }
  if (typeof result.caseName !== 'string') {
    throw new FieldTypeError('caseName', 'string', 'result', result);
  }
  if (result.timeS === undefined) {
    throw new FieldMissingError('timeS', 'result', result);
  }
  if (typeof result.timeS !== 'number') {
    throw new FieldTypeError('timeS', 'number', 'result', result);
  }
  if (result.numHints === undefined) {
    throw new FieldMissingError('numHints', 'result', result);
  }
  if (typeof result.numHints !== 'number') {
    throw new FieldTypeError('numHints', 'number', 'result', result);
  }
  if (result.success === undefined) {
    throw new FieldMissingError('success', 'result', result);
  }
  if (typeof result.success !== 'boolean') {
    throw new FieldTypeError('success', 'boolean', 'result', result);
  }
  return {
    id: result.id,
    timestamp: fromDateString(result.createdAt),
    duration: seconds(result.timeS),
    caseKey: result.caseKey,
    caseName: result.caseName,
    numHints: result.numHints,
    success: result.success,
  };
}

function createResult(trainingCase: TrainingCase, partialResult: PartialResult) {
  return {
    caseKey: trainingCase.key,
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

  list(trainingSessionId: number, offset?: number, limit?: number): Observable<Result[]> {
    return this.rails.get<RawResult[]>(`/training_sessions/${trainingSessionId}/results`, {offset, limit}).pipe(
      map(results => results.map(parseResult)));
  }

  destroy(trainingSessionId: number, resultId: number): Observable<void> {
    return this.rails.delete<void>(`/training_sessions/${trainingSessionId}/results/${resultId}`, {});
  }

  markDnf(trainingSessionId: number, resultId: number): Observable<Result> {
    return this.rails.patch<RawResult>(`/training_sessions/${trainingSessionId}/results/${resultId}`,
                                       { result: { success: false } }).pipe(
                                         map(parseResult));
  }

  create(trainingSessionId: number, trainingCase: TrainingCase, partialResult: PartialResult): Observable<Result> {
    return this.rails.post<RawResult>(`/training_sessions/${trainingSessionId}/results`,
				      { result: createResult(trainingCase, partialResult) }).pipe(
                                        map(parseResult));
  }
}
