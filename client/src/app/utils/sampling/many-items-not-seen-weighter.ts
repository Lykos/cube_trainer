import { WeightState } from './weight-state';
import { Weighter } from './weighter';

export class ManyItemsNotSeenWeighter implements Weighter {
  constructor(private readonly exponent: number) {}

  weight<X>(state: WeightState) {
    return state.itemsSinceLastOccurrence ** this.exponent;
  }
}
