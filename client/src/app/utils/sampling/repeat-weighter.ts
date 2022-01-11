import { WeightState } from './weight-state';
import { Selector } from './selector';
import { selectWithExponentialBackoff } from './select-with-exponential-backoff';

export class RepeatWeighter extends Selector {
  constructor(private readonly exponentialBackoffBase: number) {
    super();
  }

  select(state: WeightState) {
    return selectWithExponentialBackoff(this.exponentialBackoffBase, state.totalOccurrences, state.itemsSinceLastOccurrence);
  }
}

