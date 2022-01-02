import { sum } from '../utils';

interface Weighted {
  readonly weight: number;
}

export function weightedDraw<X extends Weighted>(xs: X[]): X {
  const weightSum = sum(xs.map(x => x.weight));
  if (weightSum === 0) {
    throw new Error('weight sum is 0');
  }
  let weightIndex = Math.random() * weightSum;
  for (let x of xs) {
    if (x.weight === 0) {
      continue;
    }
    if (weightIndex <= x.weight) {
      return x;
    }
    weightIndex -= x.weight;
  }
  throw new Error('used up weight sum and did not find an item');
}
