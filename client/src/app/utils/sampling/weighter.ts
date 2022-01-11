import { WeightState } from './weight-state';

export interface Weighter {
  weight(state: WeightState): number;
}
