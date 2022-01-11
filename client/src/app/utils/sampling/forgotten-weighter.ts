import { WeightState } from './weight-state';
import { Selector } from './selector';
import { selectWithExponentialBackoff } from './select-with-exponential-backoff';
import { orElse, mapOptional } from '../optional';

export class ForgottenWeighter extends Selector {
  constructor(private readonly exponentialBackoffBase: number,
              private readonly forgottenRepetitions: number) {
    super();
  }

  select(state: WeightState) {
    return orElse(
      mapOptional(
        state.occurrenceDaysSinceLastHintOrDnf,
        occurrenceDaysSince => selectWithExponentialBackoff(
          this.exponentialBackoffBase,
          occurrenceDaysSince,
          state.durationSinceLastOccurrence.toDays(),
          this.forgottenRepetitions,
        )
      ),
      false);
  }

}
