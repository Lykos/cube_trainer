import { Injectable } from '@angular/core';
import { TrainingSession } from './training-session.model';
import { map } from 'rxjs/operators';
import { TrainingCase } from './training-case.model';
import { Result } from './result.model';
import { Observable } from 'rxjs';
import { SamplingState, ItemAndWeightState } from '@utils/sampling';
import { WeightState } from '@utils/sampling';
import { Store } from '@ngrx/store';
import { selectSelectedTrainingSessionResults } from '@store/results.selectors';
import { none, some, Optional, mapOptional, ifPresent } from '@utils/optional';
import { Instant } from '@utils/instant';
import { Duration, infiniteDuration } from '@utils/duration';

interface IntermediateWeightState {
  itemsSinceLastOccurrence: number;
  durationSinceLastOccurrence: Duration;
  occurrenceDays: number[];
  totalOccurrences: number;
  lastHintInfo: Optional<{ timestamp: Instant, occurrenceDaysSince: number[] }>;
}

function initialWeightState(): IntermediateWeightState {
  return {
    itemsSinceLastOccurrence: Infinity,
    durationSinceLastOccurrence: infiniteDuration,
    occurrenceDays: [],
    lastHintInfo: none,
    totalOccurrences: 0,
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
    occurrenceDaysSinceLastHint: mapOptional(state.lastHintInfo, l => l.occurrenceDaysSince.length),
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
    weightStates.set(casee.key, { item: casee, state: initialWeightState() });
  }
  for (let i = 0; i <= results.length; ++i) {
    const result = results[i];
    const weightState = weightStates.get(result.caseKey)?.state;
    if (!weightState) {
      // Probably a result of a case that isn't available any more.
      continue;
    }
    if (result.numHints > 0) {
      weightState.lastHintInfo = some({ timestamp: result.timestamp, occurrenceDaysSince: []});
    } else {
      ifPresent(weightState.lastHintInfo, lastHintInfo => {
        const daysAgo = lastHintInfo.timestamp.durationUntil(now).toDays();
        if (lastHintInfo.occurrenceDaysSince.length === 0 || lastHintInfo.occurrenceDaysSince[lastHintInfo.occurrenceDaysSince.length - 1] != daysAgo) {
          lastHintInfo.occurrenceDaysSince.push(daysAgo);
        }
      });
    }
    const daysAgo = result.timestamp.durationUntil(now).toDays();
    if (weightState.occurrenceDays.length === 0 || weightState.occurrenceDays[weightState.occurrenceDays.length - 1] != daysAgo) {
      weightState.occurrenceDays.push(daysAgo);
    }
    weightState.itemsSinceLastOccurrence = Math.min(weightState.itemsSinceLastOccurrence, results.length - 1 - i);
    weightState.durationSinceLastOccurrence = weightState.durationSinceLastOccurrence.min(result.timestamp.durationUntil(now));
    weightState.totalOccurrences += 1;
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
      map(results => toSamplingState(now, trainingSession.trainingCases, results)),
    );
  }
}
