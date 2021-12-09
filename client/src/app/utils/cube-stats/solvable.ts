import { Probabilistic, ProbabilisticPossibility, deterministic } from './probabilistic';
import { Parity, EvenCycle, ThreeCycle, ParityTwist, DoubleSwap } from './alg';
import { Piece } from './piece';
import { OrientedType } from './oriented-type'

export function unfixedOrientedType(index: number) {
  return new PartiallyFixedOrientedType(false, index);
}

export interface Solvable<T> {
  applyCycleBreakFromSwap(cycleBreak: ThreeCycle): T;
  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): T;
  applyParity(parity: Parity, orientedType: OrientedType): T;
  applyParityTwist(parity: ParityTwist, orientedType: OrientedType): T;
  applyPartialDoubleSwap(doubleSwap: DoubleSwap): T;
  applyCompleteDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType): T;
  applyCompleteEvenCycle(doubleSwap: EvenCycle, orientedType: OrientedType): T;
  applyPartialEvenCycle(doubleSwap: EvenCycle): T;

  decideIsParityTime(): Probabilistic<[T, boolean]>;
  decideIsSolved(piece: Piece): Probabilistic<[T, boolean]>;
  decideIsPermuted(piece: Piece): Probabilistic<[T, boolean]>;
  decideOrientedTypeForPieces(piece: readonly Piece[]): Probabilistic<[T, PartiallyFixedOrientedType]>;
  decideCycleLength(piece: Piece): Probabilistic<[T, number]>;
  decideNextPiece(piece: Piece): Probabilistic<[T, Piece]>;
}
