import { Sampler } from './sampler';
import { SamplingState } from './sampling-state';
import { SamplingError } from './sampling-error';

// A sampler that has a list of samplers and uses the first one that is ready.
export class PrioritizedSampler implements Sampler {
  constructor(private readonly subsamplers: Sampler[]) {}

  ready<X>(state: SamplingState<X>) {
    return this.subsamplers.some(s => s.ready(state));
  }

  sample<X>(state: SamplingState<X>) {
    for (let subsampler of this.subsamplers) {
      if (subsampler.ready(state)) {
        return subsampler.sample(state);
      }
    }
    throw new SamplingError('no subsampler is ready');
  }
}
