import { WeightState } from './weight-state';
import { Weighter } from './weighter';

export class UniformWeighter implements Weighter {
  weight(unusedState: WeightState) {
    return 1;
  }
}
