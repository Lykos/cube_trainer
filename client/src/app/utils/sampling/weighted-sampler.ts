import { Sampler } from './sampler';
import { Weighter } from './weighter';
import { SamplingState } from './sampling-state';
import { WeightState } from './weight-state';
import { SamplingError } from './sampling-error';
import { weightedDraw } from './weighted-draw';

function isRecent(state: WeightState, recencyThreshold: number) {
  return state.itemsSinceLastOccurrence < recencyThreshold;
}

// A simple sampler (i.e. it is not a combination of other samplers) that ignores
// recent items and uses the weight from the given weighter to draw an item.
export class WeightedSampler implements Sampler {
  constructor(private readonly weighter: Weighter,
              private readonly recencyThreshold: number) {}  

  ready<X>(state: SamplingState<X>) {
    return state.weightStates.some(w => !isRecent(w.state, this.recencyThreshold) && this.weighter.weight(w.state) > 0);
  }

  sample<X>(state: SamplingState<X>) {
    const weightedItems = state.weightStates
      .filter(s => !isRecent(s.state, this.recencyThreshold))
      .map(s => ({ item: s.item, weight: this.weighter.weight(s.state) }))
      .filter(s => s.weight > 0);
    if (weightedItems.length === 0) {
      throw new SamplingError('no item has positive weight');
    }
    return weightedDraw(weightedItems).item;
  }
}
