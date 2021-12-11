import { Probabilistic, deterministic } from './probabilistic';
import { Piece } from './piece';
import { Optional, mapOptional, orElseCall, some, none } from '../optional';
import { Solvable } from './solvable';
import { Alg } from './alg';
import { AlgTrace } from './alg-trace';

export type ProbabilisticAlgTrace<T extends Solvable<T>> = Probabilistic<[T, AlgTrace]>;

export function pMapSecond<X, Y, Z>(probabilistic: Probabilistic<[X, Y]>, f: (y: Y) => Z): Probabilistic<[X, Z]> {
  return probabilistic.map(([x, y]) => [x, f(y)]);
}

export function pSecondNot<T extends Solvable<T>>(probCond: Probabilistic<[T, boolean]>): Probabilistic<[T, boolean]> {
  return pMapSecond(probCond, cond => !cond);
}

export function withPrefix<T extends Solvable<T>>(algTraces: ProbabilisticAlgTrace<T>, alg: Alg): ProbabilisticAlgTrace<T> {
  return pMapSecond(algTraces, trace => trace.withPrefix(alg));
}

export function pSecondOrElseTryCall<X, T extends Solvable<T>>(pOptX: Probabilistic<[T, Optional<X>]>, pXGen: (solvable: T) => Probabilistic<[T, Optional<X>]>): Probabilistic<[T, Optional<X>]> {
  return pOptX.flatMap(([solvable, optX]) => {
    const optPX: Optional<Probabilistic<[T, Optional<X>]>> = mapOptional(optX, x => deterministic([solvable, some(x)]));
    return orElseCall(optPX, () => pXGen(solvable));
  });
}

function pFilter<X, T extends Solvable<T>>(solvable: T, x: X, pCond: (solvable: T, x: X) => Probabilistic<[T, boolean]>): Probabilistic<[T, Optional<X>]> {
  return pMapSecond(pCond(solvable, x), answer => answer ? some(x) : none);
}

export function decideFirstPieceWithCond<T extends Solvable<T>>(
  solvable: T,
  pCond: (solvable: T, buffer: Piece) => Probabilistic<[T, boolean]>,
  pieces: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  if (pieces.length === 0) {
    return deterministic([solvable, none]);
  }
  const pMaybeGoodPiece = pFilter(solvable, pieces[0], pCond);
  return pSecondOrElseTryCall(pMaybeGoodPiece, solvable => decideFirstPieceWithCond(solvable, pCond, pieces.slice(1)));
}
