import { Duration } from '../duration';
import { Optional } from '../optional';

// Individual state of one item for weighting.
export interface WeightState {
  // How many times the item appeared in total.
  readonly totalOccurrences: number;
  readonly itemsSinceLastOccurrence: number;
  readonly durationSinceLastOccurrence: Duration;
  readonly occurrenceDays: number;
  readonly occurrenceDaysSinceLastHint: Optional<number>;
}
