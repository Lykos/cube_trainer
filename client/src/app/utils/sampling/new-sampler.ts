import { Sampler } from './sampler';
import { SamplingError } from './sampling-error';
import { SamplingState, ItemAndWeightState } from './sampling-state';
import { find } from '../utils';
import { orElseCall, mapOptional } from '../optional';

function isNew<X>(state: ItemAndWeightState<X>): boolean {
  return state.state.totalOccurrences === 0;
}

export class NewSampler implements Sampler {
  ready<X>(state: SamplingState<X>) {
    return state.weightStates.some(isNew);
  }

  sample<X>(state: SamplingState<X>) {
    return orElseCall(
      mapOptional(find(state.weightStates, isNew), s => s.item),
      () => { throw new SamplingError('no new item is present'); });
  }  
}
