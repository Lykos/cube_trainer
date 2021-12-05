import { Piece } from './piece';
import { assert } from './assert';

export class ParityTwist {
  constructor(
    readonly firstPiece: Piece,
    readonly lastPiece: Piece,
    readonly unoriented: Piece) {}
}

export class Parity {
  constructor(
    readonly firstPiece: Piece,
    readonly lastPiece: Piece) {}
}

export class ThreeCycle {
  constructor(
    readonly firstPiece: Piece, readonly secondPiece: Piece, readonly thirdPiece: Piece) {
  }
}

export class EvenCycle {
  constructor(
    readonly piece: Piece[]) {
    assert(piece.length % 2 === 1, 'uneven cycle');
  }
}

export class DoubleSwap {
  constructor(readonly firstPiece: Piece,
              readonly secondPiece: Piece,
              readonly thirdPiece: Piece,
              readonly fourthPiece: Piece) {}
}

export type Alg = ParityTwist | Parity | ThreeCycle | EvenCycle | DoubleSwap;
