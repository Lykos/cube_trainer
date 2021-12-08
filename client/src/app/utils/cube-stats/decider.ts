import { Piece } from './piece';
import { Parity, ParityTwist, DoubleSwap, Twist } from './alg';
import { BufferState } from './buffer-state';
import { TwistWithCost } from './twist-with-cost';
import { PiecePermutationDescription } from './piece-permutation-description';

export class Decider {

  readonly twistsWithCosts: TwistWithCost[];

  constructor(readonly piecePermutationDescription: PiecePermutationDescription) {
    this.twistsWithCosts = piecePermutationDescription.pieceDescription.twistGroups().filter(g => g.numUnoriented === 2).map(g => {
      return {twist: new Twist(g.unorientedByType), cost: 1};
    });
  }

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

  // Stay with this buffer if all buffers are solved.
  // If false, will switch back to the main buffer instead.
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

  maxCycleLengthForBuffer(buffer: Piece) {
    return 3;
  }
}
