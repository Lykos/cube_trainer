import { FixedSampler, NeverSampler, PrioritizedSampler } from './';
import { none } from '@utils/optional';

const samplingState = { weightStates: [], nextItem: none };

describe('PrioritizedSampler', () => {
  it('is ready if one of its subsamplers is ready', () => {
    const sampler = new PrioritizedSampler([new NeverSampler(), new FixedSampler(3)]);
    expect(sampler.ready(samplingState)).toEqual(true);
  });

  it('is not ready if none of its subsamplers is ready', () => {
    const sampler = new PrioritizedSampler([new NeverSampler(), new NeverSampler()]);
    expect(sampler.ready(samplingState)).toEqual(false);
  });

  it('uses the first ready subsampler', () => {
    const sampler = new PrioritizedSampler([new NeverSampler(), new FixedSampler(2), new FixedSampler(3)]);
    expect(sampler.sample(samplingState).item).toEqual(2);
  });
});
