import { assert } from '../assert';

// Distort the given value randomly by up to the given factor.
export function distort(value: number, factor: number) {
  assert(factor > 0 && factor < 1, 'factor has to be strictly between 0 and 1');

  return (value * (1 - factor)) + (factor * 2 * value * Math.random())
}
