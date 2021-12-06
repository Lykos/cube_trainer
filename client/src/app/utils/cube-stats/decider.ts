import { Piece } from './piece';
import { Parity, ParityTwist, DoubleSwap } from './alg';
import { BufferState } from './buffer-state';

export class Decider {
  nextCycleBreakOnSecondPiece(buffer: Piece, firstPiece: Piece, unsolvedPieces: Piece[]): Piece {
    return unsolvedPieces[0];
  }

  nextCycleBreakOnFirstPiece(buffer: Piece, unsolvedPieces: Piece[]): Piece {
    return unsolvedPieces[0];
  }

  canParityTwist(parityTwist: ParityTwist) {
    return false;
  }

  isBuffer(piece: Piece) {
    return true;
  }

  bufferPriority(piece: Piece) {
    return piece.pieceId;
  }

  stayWithSolvedBuffer(piece: Piece) {
    return true;
  }

  canChangeBuffer(bufferState: BufferState) {
    return bufferState.cycleBreaks === 0;
  }

  canDoubleSwap(doubleSwap: DoubleSwap) {
    return false;
  }

  get avoidUnorientedIfWeCanFloat() {
    return true;
  }

  doUnorientedBeforeParity(parity: Parity, unoriented: Piece) {
    return true;
  }

  doUnorientedBeforeParityTwist(parityTwist: ParityTwist, unoriented: Piece) {
    return true;
  }

  parityTwistPriority(parityTwist: ParityTwist) {
    return parityTwist.unoriented.pieceId;
  }

  canSolveNSameUnoriented(n: number) {
    return n <= 3;
  }

  get maxCycleLength() {
    return 3;
  }
}
