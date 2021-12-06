import { Probabilistic, expectedValue, deterministic } from './probabilistic';
import { AlgCountsBuilder } from './alg-counts';

describe('Probabilistic', () => {
  it('should compute the expected value for a deterministic value', () => {
    const algCounts = new AlgCountsBuilder().incrementParities().build();
    expect(expectedValue(deterministic(algCounts)).parities).toEqual(1);
  });

  it('should map answers', () => {
    const probabilistic = new Probabilistic([[1, 0.5], [2, 0.5]]);
    const mapped = probabilistic.map(i => i * 3);
    expect(mapped.possibilities).toEqual([[3, 0.5], [6, 0.5]]);
  });

  it('should flat map', () => {
    const probabilistic = new Probabilistic([[1, 0.5], [2, 0.5]]);
    const flatMapped = probabilistic.flatMap(i => new Probabilistic([[i * 3, 0.25], [i * 5, 0.75]]));
    expect(flatMapped.possibilities).toEqual([[3, 0.125], [5, 0.375], [6, 0.125], [10, 0.375]]);
  });
});
