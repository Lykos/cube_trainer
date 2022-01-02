import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { TrainingSession } from './training-session.model';
import { CubeSizeSpec } from './cube-size-spec.model';
import { Part } from './part.model';
import { StatType } from './stat-type.model';
import { AlgSet } from './alg-set.model';
import { ShowInputMode } from './show-input-mode.model';
import { NewTrainingSession } from './new-training-session.model';
import { TrainingCase } from './training-case.model';
import { TrainingSessionType } from './training-session-type.model';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { seconds } from '@utils/duration';
import { RailsParseError, FieldMissingError, FieldTypeError, ArrayTypeError } from '@shared/rails-parse-error';
import { checkObjectType, checkArrayElementTypes, checkFieldArrayElementTypes } from '@shared/rails-parse-error-checker';

interface RawTrainingCase {
  readonly caseKey?: unknown;
  readonly caseName?: unknown;
  readonly alg?: unknown;
  readonly setup?: unknown;
}

function parseTrainingCase(trainingCase: RawTrainingCase): TrainingCase {
  if (trainingCase.caseKey === undefined) {
    throw new FieldMissingError('caseKey', 'training case', trainingCase);
  }
  if (typeof trainingCase.caseKey !== 'string') {
    throw new FieldTypeError('caseKey', 'string', 'training case', trainingCase);
  }
  if (trainingCase.caseName === undefined) {
    throw new FieldMissingError('caseName', 'training case', trainingCase);
  }
  if (typeof trainingCase.caseName !== 'string') {
    throw new FieldTypeError('caseName', 'string', 'training case', trainingCase);
  }
  if (trainingCase.alg !== undefined && typeof trainingCase.alg !== 'string') {
    throw new FieldTypeError('alg', 'string', 'training case', trainingCase);
  }
  if (trainingCase.setup !== undefined && typeof trainingCase.setup !== 'string') {
    throw new FieldTypeError('setup', 'string', 'training case', trainingCase);
  }
  return {
    key: trainingCase.caseKey,
    name: trainingCase.caseName,
    alg: trainingCase.alg,
    setup: trainingCase.setup,
  };
}

function checkCubeSizeSpec(partial: Partial<CubeSizeSpec>): CubeSizeSpec {
  if (partial.default === undefined) {
    throw new FieldMissingError('default', 'stat type', partial);
  }
  if (typeof partial.default !== 'number') {
    throw new FieldTypeError('default', 'number', 'stat type', partial);
  }
  if (partial.min === undefined) {
    throw new FieldMissingError('min', 'stat type', partial);
  }
  if (typeof partial.min !== 'number') {
    throw new FieldTypeError('min', 'number', 'stat type', partial);
  }
  if (partial.max === undefined) {
    throw new FieldMissingError('max', 'stat type', partial);
  }
  if (typeof partial.max !== 'number') {
    throw new FieldTypeError('max', 'number', 'stat type', partial);
  }
  if (partial.oddAllowed === undefined) {
    throw new FieldMissingError('oddAllowed', 'stat type', partial);
  }
  if (typeof partial.oddAllowed !== 'number') {
    throw new FieldTypeError('oddAllowed', 'number', 'stat type', partial);
  }
  if (partial.evenAllowed === undefined) {
    throw new FieldMissingError('evenAllowed', 'stat type', partial);
  }
  if (typeof partial.evenAllowed !== 'number') {
    throw new FieldTypeError('evenAllowed', 'number', 'stat type', partial);
  }
  return {
    default: partial.default,
    min: partial.min,
    max: partial.max,
    oddAllowed: partial.oddAllowed,
    evenAllowed: partial.evenAllowed,
  };
}

function checkPart(partial: Partial<Part>): Part {
  if (partial.key === undefined) {
    throw new FieldMissingError('key', 'part', partial);
  }
  if (typeof partial.key !== 'string') {
    throw new FieldTypeError('key', 'string', 'part', partial);
  }
  if (partial.name === undefined) {
    throw new FieldMissingError('name', 'part', partial);
  }
  if (typeof partial.name !== 'string') {
    throw new FieldTypeError('name', 'string', 'part', partial);
  }
  return {
    name: partial.name,
    key: partial.key,
  };
}

function checkShowInputMode(showInputMode: string): ShowInputMode {
  switch (showInputMode) {
    case ShowInputMode.Picture:
    case ShowInputMode.Name:
      return showInputMode;
    default:
      throw new RailsParseError(`invalid show input mode ${showInputMode}`);
  }
}

function checkStatType(partial: Partial<StatType>): StatType {
  if (partial.key === undefined) {
    throw new FieldMissingError('key', 'stat type', partial);
  }
  if (typeof partial.key !== 'string') {
    throw new FieldTypeError('key', 'string', 'stat type', partial);
  }
  if (partial.name === undefined) {
    throw new FieldMissingError('name', 'stat type', partial);
  }
  if (typeof partial.name !== 'string') {
    throw new FieldTypeError('name', 'string', 'stat type', partial);
  }
  if (partial.description === undefined) {
    throw new FieldMissingError('description', 'stat type', partial);
  }
  if (typeof partial.description !== 'string') {
    throw new FieldTypeError('description', 'string', 'stat type', partial);
  }
  return {
    key: partial.key,
    name: partial.name,
    description: partial.description,
  };
}

function checkAlgSet(partial: Partial<AlgSet>): AlgSet {
  if (partial.owner === undefined) {
    throw new FieldMissingError('owner', 'alg set', partial);
  }
  if (typeof partial.owner !== 'string') {
    throw new FieldTypeError('owner', 'string', 'alg set', partial);
  }
  if (partial.buffer === undefined) {
    throw new FieldMissingError('buffer', 'alg set', partial);
  }
  if (typeof partial.buffer !== 'object') {
    throw new FieldTypeError('buffer', 'object', 'alg set', partial);
  }
  return {
    owner: partial.owner,
    buffer: checkPart(partial.buffer),
  };
}

export interface RawTrainingSessionType {
  readonly key?: unknown;
  readonly name?: unknown;
  readonly showInputModes?: unknown;
  readonly hasBoundedInputs?: unknown;
  readonly cubeSizeSpec?: unknown;
  readonly hasGoalBadness?: unknown;
  readonly hasMemoTime?: unknown;
  readonly hasSetup?: unknown;
  readonly buffers?: unknown;
  readonly statsTypes?: unknown;
  readonly algSets?: unknown;
}

function parseTrainingSessionType(trainingSessionType: RawTrainingSessionType): TrainingSessionType {
  checkObjectType('training session type', trainingSessionType);
  if (trainingSessionType.key === undefined) {
    throw new FieldMissingError('key', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.key !== 'string') {
    throw new FieldTypeError('key', 'string', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.name === undefined) {
    throw new FieldMissingError('name', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.name !== 'string') {
    throw new FieldTypeError('name', 'string', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.showInputModes === undefined) {
    throw new FieldMissingError('showInputModes', 'training session type', trainingSessionType);
  }
  if (!Array.isArray(trainingSessionType.showInputModes)) {
    throw new FieldTypeError('showInputModes', 'array', 'training session type', trainingSessionType);
  }
  checkFieldArrayElementTypes('showInputModes', 'string', 'training session type', trainingSessionType, trainingSessionType.showInputModes);
  if (trainingSessionType.hasBoundedInputs === undefined) {
    throw new FieldMissingError('hasBoundedInputs', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.hasBoundedInputs !== 'boolean') {
    throw new FieldMissingError('hasBoundedInputs', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.cubeSizeSpec !== undefined && typeof trainingSessionType.cubeSizeSpec !== 'object') {
    throw new FieldTypeError('cubeSizeSpec', 'object', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.hasGoalBadness === undefined) {
    throw new FieldMissingError('hasGoalBadness', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.hasGoalBadness !== 'boolean') {
    throw new FieldTypeError('hasGoalBadness', 'boolean', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.hasMemoTime === undefined) {
    throw new FieldMissingError('hasMemoTime', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.hasMemoTime !== 'boolean') {
    throw new FieldTypeError('hasMemoTime', 'boolean', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.hasSetup === undefined) {
    throw new FieldMissingError('hasSetup', 'training session type', trainingSessionType);
  }
  if (typeof trainingSessionType.hasSetup !== 'boolean') {
    throw new FieldTypeError('hasSetup', 'boolean', 'training session type', trainingSessionType);
  }
  if (trainingSessionType.buffers === undefined) {
    throw new FieldMissingError('buffers', 'training session type', trainingSessionType);
  }
  if (!Array.isArray(trainingSessionType.buffers)) {
    throw new FieldTypeError('buffers', 'array', 'training session type', trainingSessionType);
  }
  checkFieldArrayElementTypes('buffers', 'object', 'training session type', trainingSessionType, trainingSessionType.buffers);
  if (trainingSessionType.statsTypes === undefined) {
    throw new FieldMissingError('statsTypes', 'training session type', trainingSessionType);
  }
  if (!Array.isArray(trainingSessionType.statsTypes)) {
    throw new FieldTypeError('statsTypes', 'array', 'training session type', trainingSessionType);
  }
  checkFieldArrayElementTypes('statsTypes', 'object', 'training session type', trainingSessionType, trainingSessionType.statsTypes);
  if (trainingSessionType.statsTypes.some(i => typeof i !== 'object')) {
    throw new Error(`Field statsTypes contains elements not of type object in training session type ${JSON.stringify(trainingSessionType)}`);
  }
  if (trainingSessionType.algSets === undefined) {
    throw new FieldMissingError('algSets', 'training session type', trainingSessionType);
  }
  if (!Array.isArray(trainingSessionType.algSets)) {
    throw new FieldTypeError('algSets', 'array', 'training session type', trainingSessionType);
  }
  checkFieldArrayElementTypes('algSets', 'object', 'training session type', trainingSessionType, trainingSessionType.algSets);
  const cubeSizeSpec = trainingSessionType.cubeSizeSpec ? checkCubeSizeSpec(trainingSessionType.cubeSizeSpec) : undefined;
  return {
    key: trainingSessionType.key,
    name: trainingSessionType.name,
    showInputModes: trainingSessionType.showInputModes.map(checkShowInputMode),
    hasBoundedInputs: trainingSessionType.hasBoundedInputs,
    cubeSizeSpec,
    hasGoalBadness: trainingSessionType.hasGoalBadness,
    hasMemoTime: trainingSessionType.hasMemoTime,
    hasSetup: trainingSessionType.hasSetup,
    buffers: trainingSessionType.buffers.map(checkPart),
    statsTypes: trainingSessionType.statsTypes.map(checkStatType),
    algSets: trainingSessionType.algSets.map(checkAlgSet),
  };
}

interface RawTrainingSession {
  readonly id?: unknown;
  readonly trainingSessionType?: unknown;
  readonly name?: unknown;
  readonly known?: unknown;
  readonly showInputMode?: unknown;
  readonly buffer?: unknown;
  readonly goalBadness?: unknown;
  readonly memoTimeS?: unknown;
  readonly cubeSize?: unknown;
  readonly numResults?: unknown;
  readonly trainingCases?: unknown;
}

function parseTrainingSession(trainingSession: RawTrainingSession): TrainingSession {
  checkObjectType('training session', trainingSession);
  if (trainingSession.id === undefined) {
    throw new FieldMissingError('id', 'training session', trainingSession);
  }
  if (typeof trainingSession.id !== 'number') {
    throw new FieldTypeError('id', 'number', 'training session', trainingSession);
  }
  if (trainingSession.trainingSessionType === undefined) {
    throw new FieldMissingError('trainingSessionType', 'training session', trainingSession);
  }
  if (typeof trainingSession.trainingSessionType !== 'object') {
    throw new FieldTypeError('trainingSessionType', 'object', 'training session', trainingSession);
  }
  if (trainingSession.name === undefined) {
    throw new FieldMissingError('name', 'training session', trainingSession);
  }
  if (typeof trainingSession.name !== 'string') {
    throw new FieldTypeError('name', 'name', 'training session', trainingSession);
  }
  if (trainingSession.known === undefined) {
    throw new FieldMissingError('known', 'training session', trainingSession);
  }
  if (typeof trainingSession.known !== 'boolean') {
    throw new FieldTypeError('known', 'boolean', 'training session', trainingSession);
  }
  if (trainingSession.showInputMode === undefined) {
    throw new FieldMissingError('showInputMode', 'training session', trainingSession);
  }
  if (typeof trainingSession.showInputMode !== 'string') {
    throw new FieldTypeError('showInputMode', 'string', 'training session', trainingSession);
  }
  if (trainingSession.buffer !== undefined && typeof trainingSession.buffer !== 'object') {
    throw new FieldTypeError('buffer', 'object', 'training session', trainingSession);
  }
  if (trainingSession.goalBadness !== undefined && typeof trainingSession.goalBadness !== 'number') {
    throw new FieldTypeError('goalBadness', 'number', 'training session', trainingSession);
  }
  if (trainingSession.memoTimeS !== undefined && typeof trainingSession.memoTimeS !== 'number') {
    throw new FieldTypeError('memoTimeS', 'number', 'training session', trainingSession);
  }
  if (trainingSession.cubeSize !== undefined && typeof trainingSession.cubeSize !== 'number') {
    throw new FieldTypeError('cubeSize', 'number', 'training session', trainingSession);
  }
  if (trainingSession.numResults === undefined) {
    throw new FieldMissingError('numResults', 'training session', trainingSession);
  }
  if (typeof trainingSession.numResults !== 'number') {
    throw new FieldTypeError('numResults', 'number', 'training session', trainingSession);
  }
  if (trainingSession.trainingCases === undefined) {
    throw new FieldMissingError('trainingCases', 'training session', trainingSession);
  }
  if (!Array.isArray(trainingSession.trainingCases)) {
    throw new FieldTypeError('trainingCases', 'array', 'training session', trainingSession);
  }
  checkFieldArrayElementTypes('trainingCases', 'object', 'training session', trainingSession, trainingSession.trainingCases);
  return {
    id: trainingSession.id,
    trainingSessionType: parseTrainingSessionType(trainingSession.trainingSessionType as Partial<TrainingSessionType>),
    name: trainingSession.name,
    known: trainingSession.known,
    showInputMode: checkShowInputMode(trainingSession.showInputMode),
    buffer: checkPart(trainingSession.buffer as Partial<Part>),
    goalBadness: trainingSession.goalBadness,
    memoTime: trainingSession.memoTimeS ? seconds(trainingSession.memoTimeS) : undefined,
    cubeSize: trainingSession.cubeSize,
    numResults: trainingSession.numResults,
    trainingCases: trainingSession.trainingCases.map(parseTrainingCase),
  };
}

function parseTrainingSessions(trainingSessions: unknown): TrainingSession[] {
  if (!Array.isArray(trainingSessions)) {
    throw new ArrayTypeError('training sessions', trainingSessions);
  }
  checkArrayElementTypes('object', 'training sessions', trainingSessions);
  return trainingSessions.map(parseTrainingSession);
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
      map(parseTrainingSessions));
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
