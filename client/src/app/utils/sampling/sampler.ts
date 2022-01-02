import { SamplingState } from './sampling-state';

export interface Sampler {
  // Whether this sampler is ready to deliver samples.
  // This is useful because a sampler that repeats forgotten items might not have any forgotten items available.
  ready<X>(state: SamplingState<X>): boolean;

  // Get the next sample.
  // Throws a SamplingError if it is not ready.
  sample<X>(state: SamplingState<X>): X;
}
