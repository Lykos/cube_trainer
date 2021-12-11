import { Piece } from './piece';
import { PiecePermutationDescription } from './piece-permutation-description';
import { rand, swap, only, indexOf } from '../utils';
import { assert } from '../assert';
import { Solvable } from './solvable';
import { VectorSpaceElement, NumberAsVectorSpaceElement } from './vector-space-element';
import { OrientedType, orientedType, solvedOrientedType, orientedSum } from './oriented-type';
import { Optional, some, none, forceValue } from '../optional';
import { Probabilistic, deterministic } from './probabilistic';
import { Parity, EvenCycle, ThreeCycle, ParityTwist, DoubleSwap } from './alg';

function shuffle<X>(xs: X[], allowOddPermutations: boolean) {
  let isEven = true;
  const n = xs.length;
  for (let i = 0; i < n; ++i) {
    const j = i + rand(n - i);
    if (j != i) {
      swap(xs, i, j);
      isEven = !isEven;
    }
  }
  if (!isEven && !allowOddPermutations) {
    swap(xs, 0, 1);
  }
}

export class Scramble implements Solvable<Scramble> {
  constructor(readonly pieces: readonly Piece[], readonly orientedTypes: readonly OrientedType[]) {
    assert(orientedSum(this.orientedTypes).isSolved, 'oriented sum does not add up');
    for (let i = 0; i < this.pieces.length; ++i) {
      for (let j = 0; j < this.pieces.length; ++j) {
        if (i !== j) {
          assert(this.pieces[i].pieceId !== this.pieces[j].pieceId, 'piece appears multiple times');
        }
      }
    }
  }

  private applyCycle(piece: Piece, length: number) {
    const pieces = [...this.pieces];
    const orientedTypes = [...this.orientedTypes];
    const startIndex = piece.pieceId
    let lastPiece = this.pieces[startIndex];
    let cycleOrientedSum = solvedOrientedType;
    for (let i = 0; i < length - 1; ++i) {
      const index = lastPiece.pieceId;
      const currentPiece = this.pieces[index];
      pieces[index] = lastPiece;
      lastPiece = currentPiece;

      cycleOrientedSum = cycleOrientedSum.plus(this.orientedTypes[index]);
      orientedTypes[index] = solvedOrientedType;
    }
    pieces[startIndex] = lastPiece;
    orientedTypes[startIndex] = orientedTypes[startIndex].plus(cycleOrientedSum);
    return new Scramble(pieces, orientedTypes);
  }

  private transferTwist(fromPiece: Piece, toPiece: Piece) {
    const orientedTypes = [...this.orientedTypes];
    const orientedSum = orientedTypes[fromPiece.pieceId].plus(orientedTypes[toPiece.pieceId]);
    orientedTypes[toPiece.pieceId] = orientedSum;
    orientedTypes[fromPiece.pieceId] = solvedOrientedType;
    return new Scramble(this.pieces, orientedTypes);
  }

  applyCycleBreakFromSwap(cycleBreak: ThreeCycle): Scramble {
    return this.applyCycleBreak(cycleBreak);
  }

  private applyCycleBreak(cycleBreak: ThreeCycle): Scramble {
    const pieces = [...this.pieces];
    const orientedTypes = [...this.orientedTypes];
    const firstIndex = forceValue(indexOf(this.pieces, cycleBreak.firstPiece));
    const secondIndex = forceValue(indexOf(this.pieces, cycleBreak.secondPiece));
    const thirdIndex = forceValue(indexOf(this.pieces, cycleBreak.thirdPiece));
    const cycleOrientedSum = orientedTypes[firstIndex].plus(orientedTypes[secondIndex]).plus(orientedTypes[thirdIndex]);
    // Technically we don't have enough information how the orientation gets distributed.
    // Given that it doesn't matter, we just move it to the first one.
    orientedTypes[firstIndex] = cycleOrientedSum;
    orientedTypes[secondIndex] = solvedOrientedType;
    orientedTypes[thirdIndex] = solvedOrientedType;
    pieces[firstIndex] = cycleBreak.thirdPiece;
    pieces[secondIndex] = cycleBreak.firstPiece;
    pieces[thirdIndex] = cycleBreak.secondPiece;
    return new Scramble(pieces, orientedTypes);
  }

  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): Scramble {
    return this.applyCycleBreak(cycleBreak);
  }

  applyParity(parity: Parity, orientedType: OrientedType): Scramble {
    return this.applyCycle(parity.firstPiece, 2);
  }

  applyParityTwist(parityTwist: ParityTwist, orientedType: OrientedType): Scramble {
    return this.transferTwist(parityTwist.unoriented, parityTwist.firstPiece).applyCycle(parityTwist.firstPiece, 2);
  }

  applyPartialDoubleSwap(doubleSwap: DoubleSwap): Scramble {
    return this.applyCycle(doubleSwap.firstPiece, 2).applyCycle(doubleSwap.thirdPiece, 2);
  }

  applyCompleteDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType): Scramble {
    return this.applyPartialDoubleSwap(doubleSwap);
  }

  applyCompleteEvenCycle(evenCycle: EvenCycle, orientedType: OrientedType): Scramble {
    return this.applyCycle(evenCycle.firstPiece, evenCycle.length);
  }

  applyPartialEvenCycle(evenCycle: EvenCycle): Scramble {
    return this.applyCycle(evenCycle.firstPiece, evenCycle.length);
  }

  numPermuted() {
    return this.pieces.filter((p, index) => p.pieceId !== index).length;
  }

  private isMinimumInCycle(piece: Piece) {
    let current = this.nextPiece(piece);
    while (current != piece) {
      if (current.pieceId < piece.pieceId) {
        return false;
      }
      current = this.nextPiece(current);
    }
    return true;
  }

  numCycles() {
    let result = 0;
    for (let i = 0; i < this.pieces.length; ++i) {
      const piece = this.pieces[i];
      if (piece.pieceId === i) {
        continue;
      }
      if (this.isMinimumInCycle(piece)) {
        ++result;
      }
    }
    return result;
  }

  parityTime() {
    return this.numPermuted() === 2;
  }
  
  decideIsParityTime(): Probabilistic<[Scramble, boolean]> {
    return deterministic([this, this.parityTime()]);
  }

  isSolved(piece: Piece) {
    const index = piece.pieceId;
    return this.pieces[index] === piece && this.orientedTypes[index].isSolved;
  }
  
  decideIsSolved(piece: Piece): Probabilistic<[Scramble, boolean]> {
    return deterministic([this, this.isSolved(piece)]);
  }

  isPermuted(piece: Piece) {
    return this.pieces[piece.pieceId] !== piece;
  }
  
  decideIsPermuted(piece: Piece): Probabilistic<[Scramble, boolean]> {
    return deterministic([this, this.isPermuted(piece)]);
  }

  isOriented(piece: Piece) {
    return this.orientedTypes[piece.pieceId].isSolved;
  }
  
  decideIsOriented(piece: Piece): Probabilistic<[Scramble, boolean]> {
    return deterministic([this, this.isOriented(piece)]);
  }

  hasPermuted() {
    return this.pieces.some((p, index) => p.pieceId !== index);
  }

  decideHasPermuted(): Probabilistic<[Scramble, boolean]> {
    return deterministic([this, this.hasPermuted()]);
  }

  unoriented() {
    return this.pieces.filter((p, index) => p.pieceId === index && !this.orientedTypes[index].isSolved);
  }

  onlyUnoriented() {
    const unoriented = this.unoriented();
    return unoriented.length === 1 ? some(only(unoriented)) : none;
  }

  decideOnlyUnoriented(): Probabilistic<[Scramble, Optional<Piece>]> {
    return deterministic([this, this.onlyUnoriented()]);
  }

  onlyUnorientedExcept(piece: Piece) {
    const unoriented = this.unoriented();
    if (unoriented.length !== 2 || !unoriented.includes(piece)) {
      return none;
    }
    return some(only(unoriented.filter(p => p === piece)));
  }

  decideOnlyUnorientedExcept(piece: Piece): Probabilistic<[Scramble, Optional<Piece>]> {
    return deterministic([this, this.onlyUnorientedExcept(piece)]);
  }

  private sumOverCycleIndices<T extends VectorSpaceElement<T>>(piece: Piece, f: (index: number) => T): T {
    let current = this.nextPiece(piece);
    let accumulator: T = f(piece.pieceId);
    while (current != piece) {
      const nextIndex = current.pieceId;
      accumulator = accumulator.plus(f(nextIndex));
      current = this.nextPiece(current);
    }
    return accumulator;
  }

  orientedTypeForPieceCycle(piece: Piece): OrientedType {
    return this.sumOverCycleIndices(piece, index => this.orientedTypes[index]);
  }

  decideOrientedTypeForPieceCycle(piece: Piece): Probabilistic<[Scramble, OrientedType]> {
    return deterministic([this, this.orientedTypeForPieceCycle(piece)]);
  }

  decideOrientedTypes(): Probabilistic<[Scramble, readonly OrientedType[]]> {
    return deterministic([this, this.orientedTypes]);
  }

  cycleLength(piece: Piece) {
    return this.sumOverCycleIndices(piece, () => new NumberAsVectorSpaceElement(1)).value;
  }

  decideCycleLength(piece: Piece): Probabilistic<[Scramble, number]> {
    return deterministic([this, this.cycleLength(piece)]);
  }

  nextPiece(piece: Piece) {
    return this.pieces[piece.pieceId];
  }

  decideNextPiece(piece: Piece): Probabilistic<[Scramble, Piece]> {
    return deterministic([this, this.nextPiece(piece)]);
  }
}

export function randomScramble(piecePermutationDescription: PiecePermutationDescription): Scramble {
  const pieces = [...piecePermutationDescription.pieces];
  const numOrientedTypes = piecePermutationDescription.numOrientedTypes
  const orientedTypes = [...pieces].map(() => rand(numOrientedTypes)).map(index => orientedType(index, numOrientedTypes));
  orientedTypes[0] = orientedSum(orientedTypes.slice(1)).inverse;
  shuffle(pieces, piecePermutationDescription.allowOddPermutations);
  return new Scramble(pieces, orientedTypes);
}
