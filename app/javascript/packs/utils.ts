// Generally useful functions that have nothing to do with our bot or Travian.

import { Optional, some, none } from './optional';

export function flatMap<X, Y>(xs: X[], f: (x: X) => Y[]): Y[] {
  return xs.reduce((ys: Y[], x: X) => ys.concat(f(x)), []);
}

export function roundMul(value: number, n: number) {
  return Math.round(value / n) * n;
}

export function contains<X>(xs: X[], x: X) {
  return xs.some(y => y === x);
}

export function sum(xs: number[]) {
  return xs.reduce((a, b) => a + b, 0);
}

export function maxBy<X>(xs: X[], f: (x: X) => number): Optional<X> {
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

export function minBy<X>(xs: X[], f: (x: X) => number): Optional<X> {
  return maxBy(xs, (x: X) => -f(x));
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
export function only<X>(xs: X[]): X {
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

export function zip<X, Y>(xs: X[], ys: Y[]): [X, Y][] {
  if (xs.length != ys.length) {
    throw `Tried to zip arrays of different length: ${xs} and ${ys}`;
  }
  return xs.map((_, i) => [xs[i], ys[i]] as [X, Y]);
}

// Note that this function uses === for comparison. Even if two
// objects are equal, they will end up in different groups unless it's actually
// the same object.
export function groupBy<X, Y>(xs: X[], f: (x: X) => Y): [Y, X[]][] {
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

export function pointwiseApply<X, Y>(fs: ((x: X) => Y)[], xs: X[]): Y[] {
  if (fs.length !== xs.length) {
    throw "Can't do pointwise apply for arrays of different length ${fs.length} vs ${xs.length}.";
  }
  return zip(fs, xs).map(fx => {
    const [f, x] = fx;
    return f(x);
  });
}

export function sample<X>(xs: X[]): X {
  return xs[Math.floor(Math.random() * xs.length)];
}

export function intersection<X>(xs: X[], ys: X[]): X[] {
  return xs.filter(x => contains(ys, x));
}
