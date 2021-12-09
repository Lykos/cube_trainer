import { Probabilistic, mapSecond } from './probabilistic';
import { Solvable } from './solvable';
import { Alg } from './alg';

export type ProbabilisticAlgTrace = Probabilistic<[Solvable, AlgTrace]>;

export function withPrefix(algTraces: ProbabilisticAlgTrace, alg: Alg): ProbabilisticAlgTrace {
  return mapSecond(algTraces, trace => trace.withPrefix(alg));
}
