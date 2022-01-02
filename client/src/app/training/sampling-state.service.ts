import { Injectable } from '@angular/core';
import { TrainingSession } from './training-session.model';
import { map, take } from 'rxjs/operators';
import { TrainingCase } from './training-case.model';
import { Result } from './result.model';
import { Observable } from 'rxjs';
import { SamplingState, ItemAndWeightState } from '@utils/sampling';
import { WeightState } from '@utils/sampling';
import { Store } from '@ngrx/store';
import { selectSelectedTrainingSessionResults } from '@store/results.selectors';
import { none, some, Optional, mapOptional, ifPresent } from '@utils/optional';
import { Instant, fromDateString } from '@utils/instant';
import { Duration, infiniteDuration, seconds, minutes } from '@utils/duration';
import { CubeAverage } from '@utils/cube-average';

const BADNESS_MEMORY = 5;
const DNF_PENALTY = minutes(1);
const HINT_PENALTY = minutes(1);

interface IntermediateWeightState {
  itemsSinceLastOccurrence: number;
  durationSinceLastOccurrence: Duration;
  readonly occurrenceDays: number[];
  totalOccurrences: number;
  lastHintOrDnfInfo: Optional<{ timestamp: Instant, occurrenceDaysSince: number[] }>;
  readonly badnessAverage: CubeAverage;
}

function initialWeightState(): IntermediateWeightState {
  return {
    itemsSinceLastOccurrence: Infinity,
    durationSinceLastOccurrence: infiniteDuration,
    occurrenceDays: [],
    lastHintOrDnfInfo: none,
    totalOccurrences: 0,
    badnessAverage: new CubeAverage(BADNESS_MEMORY),
  }
}

interface ItemAndIntermediateWeightState {
  readonly item: TrainingCase;
  readonly state: IntermediateWeightState;
}

function toWeightState(state: IntermediateWeightState): WeightState {
  return {
    itemsSinceLastOccurrence: state.itemsSinceLastOccurrence,
    durationSinceLastOccurrence: state.durationSinceLastOccurrence,
    occurrenceDays: state.occurrenceDays.length,
    totalOccurrences: state.totalOccurrences,
    occurrenceDaysSinceLastHintOrDnf: mapOptional(state.lastHintOrDnfInfo, l => l.occurrenceDaysSince.length),
    badnessAverage: state.badnessAverage.average(),
  };
}

function toItemAndWeightState(state: ItemAndIntermediateWeightState): ItemAndWeightState<TrainingCase> {
  return {
    item: state.item,
    state: toWeightState(state.state),
  };
}

function toSamplingState(now: Instant, cases: readonly TrainingCase[], results: readonly Result[]): SamplingState<TrainingCase> {
  const weightStates = new Map<string, ItemAndIntermediateWeightState>();
  for (let casee of cases) {
    weightStates.set(casee.caseKey, { item: casee, state: initialWeightState() });
  }
  for (let i = 0; i < results.length; ++i) {
    const result = results[i];
    console.log(result);
    const weightState = weightStates.get(result.caseKey)?.state;
    if (!weightState) {
      // Probably a result of a case that isn't available any more.
      continue;
    }
    const timestamp = fromDateString(result.createdAt);
    if (result.numHints > 0 || !result.success) {
      weightState.lastHintOrDnfInfo = some({ timestamp, occurrenceDaysSince: []});
    } else {
      ifPresent(weightState.lastHintOrDnfInfo, lastHintOrDnfInfo => {
        const daysAgo = lastHintOrDnfInfo.timestamp.durationUntil(now).toDays();
        if (lastHintOrDnfInfo.occurrenceDaysSince.length === 0 || lastHintOrDnfInfo.occurrenceDaysSince[lastHintOrDnfInfo.occurrenceDaysSince.length - 1] != daysAgo) {
          lastHintOrDnfInfo.occurrenceDaysSince.push(daysAgo);
        }
      });
    }
    const daysAgo = timestamp.durationUntil(now).toDays();
    if (weightState.occurrenceDays.length === 0 || weightState.occurrenceDays[weightState.occurrenceDays.length - 1] != daysAgo) {
      weightState.occurrenceDays.push(daysAgo);
    }
    weightState.itemsSinceLastOccurrence = Math.min(weightState.itemsSinceLastOccurrence, results.length - 1 - i);
    weightState.durationSinceLastOccurrence = weightState.durationSinceLastOccurrence.min(timestamp.durationUntil(now));
    weightState.totalOccurrences += 1;
    if (!result.success) {
      weightState.badnessAverage.push(DNF_PENALTY);
    } else if (result.numHints > 0) {
      weightState.badnessAverage.push(HINT_PENALTY);
    } else {
      weightState.badnessAverage.push(seconds(result.timeS));
    }
  }
  const weightStateValues = [...weightStates.values()];
  return { weightStates: weightStateValues.map(toItemAndWeightState) };
}

@Injectable({
  providedIn: 'root',
})
export class SamplingStateService {
  constructor(private readonly store: Store) {}

  samplingState(now: Instant, trainingSession: TrainingSession): Observable<SamplingState<TrainingCase>> {
    return this.store.select(selectSelectedTrainingSessionResults).pipe(
      take(1),
      map(results => {console.log(results); return toSamplingState(now, trainingSession.trainingCases, results); }),
    );
  }
}
