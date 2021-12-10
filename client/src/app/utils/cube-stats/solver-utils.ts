import { Probabilistic } from './probabilistic';
import { Solvable } from './solvable';
import { Alg } from './alg';
import { AlgTrace } from './alg-trace';

export type ProbabilisticAlgTrace<T extends Solvable<T>> = Probabilistic<[T, AlgTrace]>;

export function pMapSecond<X, Y, Z>(probabilistic: Probabilistic<[X, Y]>, f: (y: Y) => Z): Probabilistic<[X, Z]> {
  return probabilistic.map(([x, y]) => [x, f(y)]);
}

export function withPrefix<T extends Solvable<T>>(algTraces: ProbabilisticAlgTrace<T>, alg: Alg): ProbabilisticAlgTrace<T> {
  return pMapSecond(algTraces, trace => trace.withPrefix(alg));
}
