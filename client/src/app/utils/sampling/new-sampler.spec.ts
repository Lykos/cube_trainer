import { infiniteDuration, seconds } from '@utils/duration';
import { NewSampler, SamplingState } from './';
import { none, some } from '@utils/optional';

const newWeightState = {
  totalOccurrences: 0,
  itemsSinceLastOccurrence: Infinity,
  durationSinceLastOccurrence: infiniteDuration,
  occurrenceDays: 0,
  occurrenceDaysSinceLastHintOrDnf: none,
  badnessAverage: none,
};

const seenWeightState = {
  totalOccurrences: 1,
  itemsSinceLastOccurrence: 1,
  durationSinceLastOccurrence: seconds(5),
  occurrenceDays: 1,
  occurrenceDaysSinceLastHintOrDnf: none,
  badnessAverage: some(seconds(3)),
};

describe('NewSampler', () => {
  it('is ready if there is at least one new item', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'picked',
          state: newWeightState,
        },
      ],
      nextItem: none,
    };
    const sampler = new NewSampler('new');
    expect(sampler.ready(samplingState)).toBeTrue();
  });

  it('is not ready if the only new item is the next item', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'next',
          state: newWeightState,
        },
      ],
      nextItem: some('next'),
    };
    const sampler = new NewSampler('new');
    expect(sampler.ready(samplingState)).toBeFalse();
  });

  it('is not ready if there are only seen items', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'picked',
          state: seenWeightState,
        },
      ],
      nextItem: none,
    };
    const sampler = new NewSampler('new');
    expect(sampler.ready(samplingState)).toBeFalse();
  });

  it('picks the first new item', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'picked',
          state: newWeightState,
        },
        {
          item: 'unpicked',
          state: newWeightState,
        },
      ],
      nextItem: none,
    };
    const sampler = new NewSampler('new');
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });

  it('picks no seen item', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'seen',
          state: seenWeightState,
        },
        {
          item: 'picked',
          state: newWeightState,
        },
      ],
      nextItem: none,
    };
    const sampler = new NewSampler('new');
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });

  it('picks no next item', () => {
    const samplingState: SamplingState<string> = {
      weightStates: [
        {
          item: 'next',
          state: newWeightState,
        },
        {
          item: 'picked',
          state: newWeightState,
        },
      ],
      nextItem: some('next'),
    };
    const sampler = new NewSampler('new');
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });
});
