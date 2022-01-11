import { Sampler } from './sampler';
import { SamplingState } from './sampling-state';
import { SamplingError } from './sampling-error';
import { weightedDraw } from './weighted-draw';

export interface SamplerAndWeight {
  readonly sampler: Sampler;
  readonly weight: number;
}

function ready<X>(sampler: SamplerAndWeight, state: SamplingState<X>): boolean {
  return sampler.weight > 0 && sampler.sampler.ready(state);
}

// A sampler that has a weighted list of samplers and chooses among the ready ones according to their weight.
export class CombinedSampler implements Sampler {
  constructor(private readonly subsamplers: SamplerAndWeight[]) {}

  private readySubsamplers<X>(state: SamplingState<X>) {
    return this.subsamplers.filter(s => ready(s, state));
  }

  ready<X>(state: SamplingState<X>) {
    return this.subsamplers.some(s => ready(s, state));
  }

  sample<X>(state: SamplingState<X>) {
    const readySubsamplers = this.readySubsamplers(state);
    if (readySubsamplers.length === 0) {
      throw new SamplingError('no subsampler is ready');
    }
    const subsampler = weightedDraw(readySubsamplers);
    return subsampler.sampler.sample(state);
  }
}
