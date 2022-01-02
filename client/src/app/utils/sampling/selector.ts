import { Weighter } from './weighter';
import { WeightState } from './weight-state';

// A weighter that only outputs weights 0 and 1 depending on a condition,
// but no actual weights.
export abstract class Selector implements Weighter {
  weight(state: WeightState) {
    return this.select(state) ? 1 : 0;
  }

  abstract select(state: WeightState): boolean;
}
