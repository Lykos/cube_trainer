import { Piece } from './piece';
import { assert } from '../assert';

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
    readonly pieces: Piece[]) {
    assert(pieces.length % 2 === 1, 'uneven cycle');
  }
}

export class ThreeCycle extends EvenCycle {
  constructor(
    readonly firstPiece: Piece, readonly secondPiece: Piece, readonly thirdPiece: Piece) {
    super([firstPiece, secondPiece, thirdPiece]);
  }
}

export class DoubleSwap {
  constructor(readonly firstPiece: Piece,
              readonly secondPiece: Piece,
              readonly thirdPiece: Piece,
              readonly fourthPiece: Piece) {}
}

export type Alg = ParityTwist | Parity | ThreeCycle | EvenCycle | DoubleSwap;
