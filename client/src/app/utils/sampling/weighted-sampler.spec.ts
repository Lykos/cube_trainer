import { FixedSampler, NeverSampler, CombinedSampler } from './';

const samplingState = { weightStates: [] };

describe('CombinedSampler', () => {
  it('is ready if one of its subsamplers is ready', () => {
    const sampler = new CombinedSampler([
      { sampler: new NeverSampler(), weight: 1 },
      { sampler: new FixedSampler(3), weight: 1 },
    ]);
    expect(sampler.ready(samplingState)).toEqual(true);
  });

  it('is not ready if none of its subsamplers is ready', () => {
    const sampler = new CombinedSampler([
      { sampler: new NeverSampler(), weight: 1 },
      { sampler: new NeverSampler(), weight: 1 },
    ]);
    expect(sampler.ready(samplingState)).toEqual(false);
  });

  it('uses the unique ready subsampler if it exists', () => {
    const sampler = new CombinedSampler([
      { sampler: new NeverSampler(), weight: 1 },
      { sampler: new FixedSampler(3), weight: 1 },
    ]);
    expect(sampler.sample(samplingState).item).toEqual(3);
  });
});
