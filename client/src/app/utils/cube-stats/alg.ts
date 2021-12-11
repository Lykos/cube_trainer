import { Piece } from './piece';
import { assert } from '../assert';
import { sum } from '../utils';

export class ParityTwist {
  constructor(
    readonly firstPiece: Piece,
    readonly lastPiece: Piece,
    readonly unoriented: Piece) {}

  get pieces() {
    return [this.firstPiece, this.lastPiece, this.unoriented];
  }

  get swappedPieces() {
    return [this.firstPiece, this.lastPiece];
  }
}

export class Parity {
  constructor(
    readonly firstPiece: Piece,
    readonly lastPiece: Piece) {}

  get pieces() {
    return [this.firstPiece, this.lastPiece];
  }
}

export class EvenCycle {
  constructor(
    readonly firstPiece: Piece,
    readonly numRemainingPieces: number) {
    assert(numRemainingPieces % 2 === 0, 'uneven cycle');
  }

  get length() {
    return this.numRemainingPieces + 1;
  }
}

export class ThreeCycle extends EvenCycle {
  constructor(firstPiece: Piece, readonly secondPiece: Piece, readonly thirdPiece: Piece) {
    super(firstPiece, 2);
  }
}

export class DoubleSwap {
  constructor(readonly firstPiece: Piece,
              readonly secondPiece: Piece,
              readonly thirdPiece: Piece,
              readonly fourthPiece: Piece) {}
}

export class Twist {
  constructor(readonly unorientedByType: readonly (readonly Piece[])[]) {}

  get numUnoriented() {
    return sum(this.unorientedByType.map(e => e.length));
  }
}

export type Alg = ParityTwist | Parity | ThreeCycle | EvenCycle | DoubleSwap | Twist;
