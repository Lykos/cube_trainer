import { WeightState } from './weight-state';

// A weighter that always returns the same weight.
// Useful only for testing and debugging.
export class FixedWeighter {
  constructor(private readonly value: number) {}

  weight(state: WeightState) {
    return this.value;
  }
}
