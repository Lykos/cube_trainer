import { assert } from './assert';
import { zeroDuration, Duration } from './duration';
import { Optional, some, none } from './optional';

const REMOVED_FRACTION = 0.05;

export class CubeAverage {
  durations: Duration[] = [];

  constructor(readonly desiredLength: number) {}

  push(duration: Duration) {
    this.durations.push(duration);
    if (this.durations.length > this.desiredLength) {
      this.durations.shift();
    }
  }

  average(): Optional<Duration> {
    if (this.durations.length === 0) {
      return none;
    }
    const sorted = [...this.durations];
    sorted.sort(d => d.toMillis());
    const removedLength = sorted.length < 3 ? 0 : Math.ceil(sorted.length * REMOVED_FRACTION);
    const keptLength = sorted.length - 2 * removedLength;
    assert(keptLength > 0);
    let sum = zeroDuration;
    for (let i = removedLength; i < sorted.length - removedLength; ++i) {
      sum = sum.plus(sorted[i]);
    }
    return some(sum.times(1.0 / keptLength));
  }
}
