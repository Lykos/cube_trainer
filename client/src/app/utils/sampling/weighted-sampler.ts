import { Sampler } from './sampler';
import { Sample } from './sample';
import { Weighter } from './weighter';
import { SamplingState, ItemAndWeightState } from './sampling-state';
import { SamplingError } from './sampling-error';
import { weightedDraw } from './weighted-draw';
import { Optional, some, none, orElse, equalsValue, hasValue } from '@utils/optional';

function isRecent<X>(samplingState: SamplingState<X>, weightState: ItemAndWeightState<X>, recencyThreshold: number) {
  const numItems = samplingState.weightStates.length

  // We always exclude the next item unless there is only one item.
  if (numItems > 1 && equalsValue(weightState.item, samplingState.nextItem)) {
    return true;
  }
  const recencyThresholdMalus = hasValue(samplingState.nextItem) ? 1 : 0;
  
  // In case of very few total items, we have to soften the recency threshold.
  const adjustedRecencyThreshold = Math.min(Math.floor(numItems / 2), recencyThreshold - recencyThresholdMalus);
  return weightState.state.itemsSinceLastOccurrence < adjustedRecencyThreshold;
}

interface WeightedItem<X> {
  readonly item: X;
  readonly weight: number;
}

// A simple sampler (i.e. it is not a combination of other samplers) that ignores
// recent items and uses the weight from the given weighter to draw an item.
export class WeightedSampler implements Sampler {
  cachedWeightedItems: Optional<WeightedItem<any>[]> = none;

  constructor(private readonly name: string,
              private readonly weighter: Weighter,
              private readonly recencyThreshold: number) {}  

  ready<X>(state: SamplingState<X>) {
    return this.weightedItems(state).length > 0;
  }

  sample<X>(state: SamplingState<X>): Sample<X> {
    const weightedItems = this.weightedItems(state);
    if (weightedItems.length === 0) {
      throw new SamplingError(`no item has positive weight in sampler ${this.name}`);
    }
    const item = weightedDraw(weightedItems).item;
    this.cachedWeightedItems = none;
    return { item, samplerName: this.name };
  }

  private weightedItems<X>(state: SamplingState<X>): WeightedItem<X>[] {
    const result = orElse(
      this.cachedWeightedItems,
      state.weightStates
	.filter(s => !isRecent(state, s, this.recencyThreshold))
	.map(s => ({ item: s.item, weight: this.weighter.weight(s.state) }))
	.filter(s => s.weight > 0)
    );
    this.cachedWeightedItems = some(result);
    return result;
  }
}
