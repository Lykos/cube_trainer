import { Sampler } from './sampler';
import { SamplingState } from './sampling-state';

// A sampler that is always ready and always returns the same element.
// Useful only for testing and debugging.
export class FixedSampler implements Sampler {
  constructor(private readonly value: any) {}

  ready<X>(state: SamplingState<X>) {
    return true;
  }

  sample<X>(state: SamplingState<X>) {
    return {
      item: this.value,
      samplerName: 'fixed',
    };
  }
}
