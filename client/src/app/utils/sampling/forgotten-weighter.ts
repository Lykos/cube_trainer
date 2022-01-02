import { WeightState } from './weight-state';
import { Selector } from './selector';
import { selectWithExponentialBackoff } from './select-with-exponential-backoff';
import { orElse, mapOptional } from '../optional';

export class ForgottenWeighter extends Selector {
  constructor(private readonly exponentialBackoffBase: number) {
    super();
  }

  select(state: WeightState) {
    return orElse(
      mapOptional(
        state.occurrenceDaysSinceLastHint,
        occurrenceDaysSinceLastHint => selectWithExponentialBackoff(this.exponentialBackoffBase, occurrenceDaysSinceLastHint, state.durationSinceLastOccurrence.toDays())
      ),
      false);
  }

}
