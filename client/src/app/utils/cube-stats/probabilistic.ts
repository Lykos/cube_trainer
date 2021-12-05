import { assert } from '../assert';
import { sum } from '../utils';
import { VectorSpaceElement, sumVectorSpaceElements } from './vector-space-element';

export type Probability = number;

export type ProbabilisticPossibility<X> = [X, Probability];

const EPSILON = 0.00001;

// This is a monad.
export class Probabilistic<X> {
  constructor(readonly possibilities: ProbabilisticPossibility<X>[]) {
    assert(Math.abs(sum(possibilities.map(possibility => possibility[1])) - 1) < EPSILON);
  }

  map<Y>(f: (x: X) => Y): Probabilistic<Y> {
    return new Probabilistic<Y>(this.possibilities.map(
      (x: ProbabilisticPossibility<X>) => {
        const [possibility, probability] = x;
        return [f(possibility), probability];
      }
    ));
  }

  flatMap<Y>(f: (x: X) => Probabilistic<Y>): Probabilistic<Y> {
    return new Probabilistic<Y>(this.possibilities.flatMap(
      (x: ProbabilisticPossibility<X>) => {
        const [possibility, probability] = x;
        return f(possibility).timesProbability(probability).possibilities;
      }
    ));
  }

  timesProbability(probabilityFactor: Probability) {
    return new Probabilistic<X>(this.possibilities.map(
      (x: ProbabilisticPossibility<X>) => {
        const [possibility, probability] = x;
        return [possibility, probability * probabilityFactor];
      }
    ));
  }

  assertDeterministic(): X {
    assert(this.possibilities.length === 1);
    return this.possibilities[0][0];
  }
}

export function flattenProbabilistic<X, Y extends Probabilistic<X>>(probabilistic: Probabilistic<Y>): Probabilistic<X> {
  return new Probabilistic<X>(probabilistic.possibilities.flatMap(
    (probabilisticAndProbability: ProbabilisticPossibility<Y>) => {
      const [innerProbabilistic, probability] = probabilisticAndProbability;
      return innerProbabilistic.timesProbability(probability).possibilities;
    }
  ));
}

export function deterministic<X>(x: X): Probabilistic<X> {
  return new Probabilistic<X>([[x, 1]]);
}

export function expectedValue<X extends VectorSpaceElement<X>>(probabilisticValue: Probabilistic<X>): X {
  return sumVectorSpaceElements(probabilisticValue.possibilities.map(valueAndProbability => {
    const [value, probability] = valueAndProbability;
    return value.times(probability);
  }));
}
