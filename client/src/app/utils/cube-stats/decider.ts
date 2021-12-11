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

  sortedNextCycleBreaksOnSecondPiece(buffer: Piece, firstPiece: Piece): readonly Piece[] {
    return this.piecePermutationDescription.pieces;
  }

  sortedNextCycleBreaksOnFirstPiece(buffer: Piece): readonly Piece[] {
    return this.piecePermutationDescription.pieces;
  }

  // Pieces that can be twisted in combination with the given parity. Sorted by priority.
  sortedParityTwistUnorientedsForParity(parity: Parity): readonly Piece[] {
    return [];
  }

  get sortedBuffers(): readonly Piece[] {
    return [this.piecePermutationDescription.pieces[0]];
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

  maxCycleLengthForBuffer(buffer: Piece) {
    return 3;
  }
}
