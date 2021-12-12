import { Piece } from './piece';
import { assert } from '../assert';
import { Parity, ParityTwist, DoubleSwap, Twist } from './alg';
import { BufferState } from './buffer-state';
import { orientedType } from './oriented-type';
import { TwistWithCost } from './twist-with-cost';
import { PiecePermutationDescription } from './piece-permutation-description';
import { PieceMethodDescription } from './method-description';

// Responsible for making decisions during the solve, e.g. which buffer we should use net.
// Interprets the method description to make these decisions.
export class Decider {
  readonly twistsWithCosts: TwistWithCost[];

  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly methodDescription: PieceMethodDescription) {
    const numOrientedTypes = this.piecePermutationDescription.numOrientedTypes;
    const numPieces = this.piecePermutationDescription.pieces.length;
    this.twistsWithCosts = methodDescription.twistsWithCosts.map(t => {
      const orientedTypes = t.twistOrientedTypeIndices.map(o => orientedType(o, numOrientedTypes));
      assert(orientedTypes.length === numPieces);
      return {twist: new Twist(orientedTypes), cost: t.cost};
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
    return this.methodDescription.sortedBuffers;
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
