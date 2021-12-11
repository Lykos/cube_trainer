import { Probabilistic } from './probabilistic';
import { Parity, EvenCycle, ThreeCycle, ParityTwist, DoubleSwap } from './alg';
import { Piece } from './piece';
import { OrientedType } from './oriented-type'
import { Optional } from '../optional';

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
  decideIsOriented(piece: Piece): Probabilistic<[T, boolean]>;
  decideHasPermuted(): Probabilistic<[T, boolean]>;

  // Decides if this solvable has exactly one unoriented piece and returns it.
  // Returns none otherwise.
  decideOnlyUnoriented(): Probabilistic<[T, Optional<Piece>]>;

  // Decides if this solvable has exactly one unoriented piece except for the given one and returns it.
  // Returns none otherwise.
  decideOnlyUnorientedExcept(piece: Piece): Probabilistic<[T, Optional<Piece>]>;

  decideOrientedTypeForPieceCycle(piece: Piece): Probabilistic<[T, OrientedType]>;
  decideUnorientedByType(): Probabilistic<[T, readonly (readonly Piece[])[]]>;
  decideCycleLength(piece: Piece): Probabilistic<[T, number]>;
  decideNextPiece(piece: Piece): Probabilistic<[T, Piece]>;
}
