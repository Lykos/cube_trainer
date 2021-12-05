type Probability = number;

type ProbabilisticPossibility<X> = [X, Probability];

// This is a monad.
class Probabilistic<X> {
  constructor(readonly possibilities: ProbabilisticPossibility<X>[]) {}

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
