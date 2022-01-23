import { Sampler } from './sampler';
import { Sample } from './sample';
import { SamplingState } from './sampling-state';
import { SamplingError } from './sampling-error';

// A sampler that has a list of samplers and uses the first one that is ready.
export class NeverSampler implements Sampler {
  ready<X>(state: SamplingState<X>) {
    return false;
  }

  sample<X>(state: SamplingState<X>): Sample<X> {
    throw new SamplingError('never sampler is never ready');
  }
}
