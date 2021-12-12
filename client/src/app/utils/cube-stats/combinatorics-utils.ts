import { assert } from '../assert';

// Multiplies integers between n and m, both ends included.
function rangeProduct(n: number, m: number) {
  let result = 1;
  for (let i = n; i <= m; ++i) {
    result *= i;
  }
  return result;
}

export function factorial(n: number) {
  assert(n >= 0, 'n in factorial(n) has to be positive');
  return rangeProduct(1, n);
}

export function ncr(n: number, r: number) {
  assert(r >= 0, 'r >= 0 in range(n, r)');
  assert(n >= r, 'n >= r in range(n, r)');
  if (r > n - r) {
    r = n - r;
  }
  return rangeProduct(n - r + 1, n) / factorial(r);
}

