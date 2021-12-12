import { Piece } from './piece';
import { assert } from '../assert';
import { count } from '../utils';
import { OrientedType } from './oriented-type';

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
  constructor(readonly orientedTypes: readonly OrientedType[]) {}

  get numUnoriented() {
    return count(this.orientedTypes, e => !e.isSolved);
  }
}

export type Alg = ParityTwist | Parity | ThreeCycle | EvenCycle | DoubleSwap | Twist;
