import { WeightState } from './weight-state';
import { Weighter } from './weighter';
import { Duration } from '../duration';
import { mapOptional, orElse } from '../optional';

export class BadnessWeighter implements Weighter {
  constructor(private readonly goalBadness: Duration, private readonly base: number) {}

  weight(state: WeightState) {
    return orElse(
      mapOptional(
        state.badnessAverage,
        a => this.weightInternal(a)),
      0);
  }

  private weightInternal(badnessAverage: Duration) {
    const badBadness = (badnessAverage.minus(this.goalBadness)).dividedBy(this.goalBadness);
    if (badBadness <= 0) {
      return 0;
    }

    return this.base ** badBadness;
  }
}
