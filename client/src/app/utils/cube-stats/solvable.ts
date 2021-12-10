import { Probabilistic } from './probabilistic';
import { Parity, EvenCycle, ThreeCycle, ParityTwist, DoubleSwap } from './alg';
import { Piece } from './piece';
import { OrientedType } from './oriented-type'

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
  decideHasPermuted(): Probabilistic<[T, boolean]>;
  decideOrientedTypeForPiece(piece: Piece): Probabilistic<[T, OrientedType]>;
  decideUnorientedByType(): Probabilistic<[T, readonly (readonly Piece[])[]]>;
  decideCycleLength(piece: Piece): Probabilistic<[T, number]>;
  decideNextPiece(piece: Piece): Probabilistic<[T, Piece]>;
}
