import { FixedWeighter, WeightedSampler, SamplingState } from './';
import { infiniteDuration } from '@utils/duration';
import { none, some } from '@utils/optional';

const weightState = {
  totalOccurrences: 0,
  itemsSinceLastOccurrence: Infinity,
  durationSinceLastOccurrence: infiniteDuration,
  occurrenceDays: 0,
  occurrenceDaysSinceLastHintOrDnf: none,
  badnessAverage: none,
};

const samplingState: SamplingState<string> = {
  weightStates: [
    {
      item: 'picked',
      state: weightState,
    },
  ],
  nextItem: none,
};

describe('WeightedSampler', () => {
  it('is ready if one of the items has a positive weight', () => {
    const sampler = new WeightedSampler('test sampler', new FixedWeighter(1), 2);
    expect(sampler.ready(samplingState)).toEqual(true);
  });

  it('is not ready if none of the items has a positive weight', () => {
    const sampler = new WeightedSampler('test sampler', new FixedWeighter(-1), 2);
    expect(sampler.ready(samplingState)).toEqual(false);
  });

  it('uses the unique item if it exists', () => {
    const sampler = new WeightedSampler('test sampler', new FixedWeighter(1), 2);
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });

  it('uses the unique non-recent item if it exists', () => {
    const recentWeightState = {
      ...weightState,
      itemsSinceLastOccurrence: 0,
    }
    const samplingState: SamplingState<string> = {
      weightStates: [
	{
	  item: 'picked',
	  state: weightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
      ],
      nextItem: none,
    };
    const sampler = new WeightedSampler('test sampler', new FixedWeighter(1), 2);
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });

  it('uses the unique non-recent item if it exists', () => {
    const recentWeightState = {
      ...weightState,
      itemsSinceLastOccurrence: 0,
    }
    const samplingState: SamplingState<string> = {
      weightStates: [
	{
	  item: 'picked',
	  state: weightState,
	},
	{
	  item: 'next',
	  state: weightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
	{
	  item: 'recent',
	  state: recentWeightState,
	},
      ],
      nextItem: some('next'),
    };
    const sampler = new WeightedSampler('test sampler', new FixedWeighter(1), 2);
    expect(sampler.sample(samplingState).item).toEqual('picked');
  });
});
