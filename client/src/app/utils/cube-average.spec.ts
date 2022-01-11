import { CubeAverage } from './cube-average';
import { seconds } from './duration';
import { none, forceValue } from './optional';

describe('CubeAverage', () => {
  it('returns undefined when no value has been set', () => {
    expect(new CubeAverage(5).average()).toEqual(none);
  });

  it('returns its only value when only one value has been set', () => {
    const cubeAverage = new CubeAverage(5);
    cubeAverage.push(seconds(1));
    expect(forceValue(cubeAverage.average()).toSeconds()).toEqual(1);
  });

  it('returns the average when only two values have been set', () => {
    const cubeAverage = new CubeAverage(5);
    cubeAverage.push(seconds(1));
    cubeAverage.push(seconds(3));
    expect(forceValue(cubeAverage.average()).toSeconds()).toEqual(2);
  });

  it('returns the middle one when only three values have been set', () => {
    const cubeAverage = new CubeAverage(5);
    cubeAverage.push(seconds(1));
    cubeAverage.push(seconds(4));
    cubeAverage.push(seconds(10));
    expect(forceValue(cubeAverage.average()).toSeconds()).toEqual(4);
  });

  it('returns the average of the middle two when four values have been set', () => {
    const cubeAverage = new CubeAverage(5);
    cubeAverage.push(seconds(1));
    cubeAverage.push(seconds(4));
    cubeAverage.push(seconds(6));
    cubeAverage.push(seconds(100));
    expect(forceValue(cubeAverage.average()).toSeconds()).toEqual(5);
  });
});
