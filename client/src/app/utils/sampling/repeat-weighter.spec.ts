import { RepeatWeighter, WeightState } from './';
import { infiniteDuration } from '@utils/duration';
import { none } from '@utils/optional';

const emptyWeightState: WeightState = {
  totalOccurrences: 0,
  itemsSinceLastOccurrence: Infinity,
  durationSinceLastOccurrence: infiniteDuration,
  occurrenceDays: 0,
  occurrenceDaysSinceLastHintOrDnf: none,
  badnessAverage: none,
};

fdescribe('RepeatWeighter', () => {
  it('selects nothing if no item has been seen', () => {
    const weighter = new RepeatWeighter(2);
    expect(weighter.weight(emptyWeightState)).toEqual(0);
  });

  it('selects a relatively item that needs to be repeated', () => {
    const weighter = new RepeatWeighter(2);
    const weightState: WeightState = { ...emptyWeightState, totalOccurrences: 1, itemsSinceLastOccurrence: 3 };
    expect(weighter.weight(weightState)).toEqual(1);
  });


  it('does not select a relatively item that needs to be repeated', () => {
    const weighter = new RepeatWeighter(2);
    const weightState: WeightState = { ...emptyWeightState, totalOccurrences: 1, itemsSinceLastOccurrence: 0 };
    expect(weighter.weight(weightState)).toEqual(0);
  });

  it('selects a mature item that needs to be repeated', () => {
    const weighter = new RepeatWeighter(2);
    const weightState: WeightState = { ...emptyWeightState, totalOccurrences: 7, itemsSinceLastOccurrence: 154 };
    expect(weighter.weight(weightState)).toEqual(1);
  });

  it('does not select a mature item that does not need to be repeated', () => {
    const weighter = new RepeatWeighter(2);
    const weightState: WeightState = { ...emptyWeightState, totalOccurrences: 7, itemsSinceLastOccurrence: 102 };
    expect(weighter.weight(weightState)).toEqual(0);
  });
});
