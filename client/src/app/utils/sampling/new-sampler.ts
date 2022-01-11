import { Sampler } from './sampler';
import { Sample } from './sample';
import { SamplingError } from './sampling-error';
import { SamplingState, ItemAndWeightState } from './sampling-state';
import { find } from '../utils';
import { orElseCall, mapOptional } from '../optional';

function isNew<X>(state: ItemAndWeightState<X>): boolean {
  return state.state.totalOccurrences === 0;
}

export class NewSampler implements Sampler {
  constructor(private readonly name: string) {}

  ready<X>(state: SamplingState<X>) {
    return state.weightStates.some(isNew);
  }

  sample<X>(state: SamplingState<X>): Sample<X> {
    return orElseCall(
      mapOptional(find(state.weightStates, isNew), s => this.toSample(s)),
      () => { throw new SamplingError('no new item is present'); });
  }  

  private toSample<X>(state: ItemAndWeightState<X>): Sample<X> {
    return {
      item: state.item,
      samplerName: this.name,
    };
  }
}
