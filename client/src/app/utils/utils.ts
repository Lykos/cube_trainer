// Generally useful functions that have nothing to do with our bot or Travian.

import { Optional, some, none, mapOptional } from './optional';
import { assert } from './assert';

export function first<X>(xs: readonly X[]): Optional<X> {
  if (xs.length >= 1) {
    return some(xs[0]);
  } else {
    return none;
  }
}

export function subsets<X>(xs: readonly X[]): X[][] {
  let result: X[][] = [[]];
  for (let x of xs) {
    result = result.concat(result.map(ys => ys.concat([x])));
  }
  return result;
}

export function combination<X>(xs: readonly X[], k: number): X[][] {
  assert(k <= xs.length);
  let result: X[][] = [[]];
  for (let x of xs) {
    result = result.concat(result.flatMap(ys => ys.length >= k ? [] : [ys.concat([x])]));
  }
  return result.filter(xs => xs.length === k);
}

export function flatMap<X, Y>(xs: readonly X[], f: (x: X) => Y[]): Y[] {
  return xs.reduce((ys: Y[], x: X) => ys.concat(f(x)), []);
}

export function roundMul(value: number, n: number) {
  return Math.round(value / n) * n;
}

export function contains<X>(xs: readonly X[], x: X) {
  return xs.some(y => y === x);
}

export function sum(xs: readonly number[]) {
  return xs.reduce((a, b) => a + b, 0);
}

export function count<X>(xs: readonly X[], f: (x: X) => boolean): number {
  return xs.reduce((a, b) => a + (f(b) ? 1 : 0), 0);
}

export function maxBy<X>(xs: readonly X[], f: (x: X) => number): Optional<X> {
  let maxX: Optional<X> = none;
  let maxY = -Infinity;
  for (let x of xs) {
    const y = f(x);
    if (y > maxY) {
      maxX = some(x);
      maxY = y;
    }
  }
  return maxX;
}

export function minBy<X>(xs: readonly X[], f: (x: X) => number): Optional<X> {
  return maxBy(xs, (x: X) => -f(x));
}

export function findIndex<X>(xs: readonly X[], f: (x: X) => boolean): Optional<number> {
  const index = xs.findIndex(f);
  return index === -1 ? none : some(index);
}

export function find<X>(xs: readonly X[], f: (x: X) => boolean): Optional<X> {
  return mapOptional(findIndex(xs, f), i => xs[i]);
}

export function indexOf<X>(xs: readonly X[], x: X): Optional<number> {
  return findIndex(xs, y => y === x);
}

// Returns a range that includes start but doesn't include end.
export function range(start: number, end: number): number[] {
  const result: number[] = [];
  for (let i = start; i < end; ++i) {
    result.push(i);
  }
  return result;
}

// Takes the unique element of an array.
export function only<X>(xs: readonly X[]): X {
  if (xs.length != 1) {
    throw `Tried to take the only element of an array ${JSON.stringify(xs)}.`;
  }
  return xs[0];
}

export function swap<X>(xs: X[], i: number, j: number) {
  [xs[i], xs[j]] = [xs[j], xs[i]];
}

export function compose<X, Y, Z>(f: (x: X) => Y, g: (y: Y) => Z): (x: X) => Z {
  return (x: X) => g(f(x));
}

export function rand(n: number) {
  return Math.floor(Math.random() * n);
}

export function shuffle<X>(xs: X[]) {
  const n = xs.length;
  for (let i = 0; i < n; ++i) {
    const j = i + rand(n - i);
    if (j != i) {
      swap(xs, i, j);
    }
  }
}

export function zip<X, Y>(xs: readonly X[], ys: readonly Y[]): [X, Y][] {
  if (xs.length != ys.length) {
    throw `Tried to zip arrays of different length: ${xs} and ${ys}`;
  }
  return xs.map((_, i) => [xs[i], ys[i]] as [X, Y]);
}

// Note that this function uses === for comparison. Even if two
// objects are equal, they will end up in different groups unless it's actually
// the same object.
export function groupBy<X, Y>(xs: readonly X[], f: (x: X) => Y): [Y, X[]][] {
  const grouped: [Y, X[]][] = [];
  for (let x of xs) {
    const y = f(x);
    let found = false;
    for (let [y2, x2s] of grouped) {
      if (y2 === y) {
        x2s.push(x);
        found = true;
      }
    }
    if (!found) {
      grouped.push([y, [x]]);
    }
  }
  return grouped;
}

export function id<X>(x: X): X {
  return x;
}

// Don't use this, it's broken.
export function hasIntegerHoles(xs: number[]) {
  const sortedXs = xs.slice();
  sortedXs.sort();
  return sortedXs.map((v, i, array) => i === array.length - 1 || v === array[i + 1] || v + 1 === array[i + 1]).some(b => !b);
}

export function repeat<X>(x: X, n: number): X[] {
  return range(0, n).map(_ => x);
}

export function pointwiseApply<X, Y>(fs: ((x: X) => Y)[], xs: readonly X[]): Y[] {
  if (fs.length !== xs.length) {
    throw "Can't do pointwise apply for arrays of different length ${fs.length} vs ${xs.length}.";
  }
  return zip(fs, xs).map(fx => {
    const [f, x] = fx;
    return f(x);
  });
}

export function sample<X>(xs: readonly X[]): X {
  return xs[rand(xs.length)];
}

export function intersection<X>(xs: readonly X[], ys: readonly X[]): X[] {
  return xs.filter(x => contains(ys, x));
}
