import { Piece } from './piece';
import { PiecePermutationDescription } from './piece-permutation-description';
import { rand, swap, only, indexOf } from '../utils';
import { Solvable } from './solvable';
import { OrientedType, orientedType, solvedOrientedType } from './oriented-type';
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
  constructor(readonly pieces: readonly Piece[], readonly orientedTypes: readonly OrientedType[], readonly numOrientedTypes: number) {}

  get numUnorientedTypes() {
    return this.numOrientedTypes - 1;
  }

  private applyCycle(piece: Piece, length: number) {
    const pieces = [...this.pieces];
    const orientedTypes = [...this.orientedTypes];
    const startIndex = forceValue(indexOf(this.pieces, piece));
    let lastPiece = piece;
    let orientedSum = 0;
    for (let i = 0; i < length - 1; ++i) {
      const index = lastPiece.pieceId;
      const currentPiece = this.pieces[index];
      pieces[index] = lastPiece;
      lastPiece = currentPiece;

      orientedSum += this.orientedTypes[index].index;
      orientedTypes[index] = solvedOrientedType;
    }
    pieces[startIndex] = lastPiece;
    orientedTypes[startIndex] = orientedType(orientedSum % this.numOrientedTypes);
    return new Scramble(pieces, orientedTypes, this.numOrientedTypes);
  }

  private transferTwist(fromPiece: Piece, toPiece: Piece) {
    const orientedTypes = [...this.orientedTypes];
    const orientedSum = (orientedTypes[fromPiece.pieceId].index + orientedTypes[toPiece.pieceId].index);
    orientedTypes[toPiece.pieceId] = orientedType(orientedSum % this.numOrientedTypes);
    orientedTypes[fromPiece.pieceId] = solvedOrientedType;
    return new Scramble(this.pieces, orientedTypes, this.numOrientedTypes);
  }

  applyCycleBreakFromSwap(cycleBreak: ThreeCycle): Scramble {
    return this.applyCycle(cycleBreak.firstPiece, 3);
  }

  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): Scramble {
    return this.applyCycle(cycleBreak.firstPiece, 3);
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

  parityTime() {
    return this.pieces.map((p, index) => p.pieceId !== index).length === 2;
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

  private sumOverCycleIndices(piece: Piece, f: (index: number) => number) {
    let current = this.nextPiece(piece);
    let accumulator = f(piece.pieceId);
    while (current != piece) {
      const nextIndex = current.pieceId;
      accumulator += f(nextIndex);
      current = this.pieces[nextIndex];
    }
    return accumulator;
  }

  orientedTypeForPieceCycle(piece: Piece): OrientedType {
    return orientedType(this.sumOverCycleIndices(piece, index => this.orientedTypes[index].index) % this.numOrientedTypes);
  }

  decideOrientedTypeForPieceCycle(piece: Piece): Probabilistic<[Scramble, OrientedType]> {
    return deterministic([this, this.orientedTypeForPieceCycle(piece)]);
  }

  unorientedByType() {
    const unorientedByType: Piece[][] = [];
    for (let i = 0; i < this.numUnorientedTypes; ++i) {
      unorientedByType.push([]);
    }
    for (let piece of this.pieces) {
      const orientedType = this.orientedTypes[piece.pieceId];
      if (orientedType.isSolved) {
        continue;
      }
      const unorientedType = orientedType.index - 1;
      unorientedByType[unorientedType].push(piece);
    }
    return unorientedByType;
  }

  decideUnorientedByType(): Probabilistic<[Scramble, readonly (readonly Piece[])[]]> {
    return deterministic([this, this.unorientedByType()]);
  }

  cycleLength(piece: Piece) {
    return this.sumOverCycleIndices(piece, () => 1);
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
  const orientedTypes = [...pieces].map(() => rand(piecePermutationDescription.orientedTypes)).map(orientedType);
  shuffle(pieces, piecePermutationDescription.allowOddPermutations);
  return new Scramble(pieces, orientedTypes, piecePermutationDescription.orientedTypes);
}
