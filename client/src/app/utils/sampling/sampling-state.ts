import { WeightState } from './weight-state';
import { Optional } from '@utils/optional';

export interface ItemAndWeightState<X> {
  readonly item: X;
  readonly state: WeightState;
}

export interface SamplingState<X> {
  // The order matters. New items are introduced in the way that they are ordered.
  readonly weightStates: readonly ItemAndWeightState<X>[];

  // An already known next item.
  readonly nextItem: Optional<X>;
}
