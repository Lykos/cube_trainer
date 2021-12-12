import { Piece } from './piece';
import { find } from '../utils';
import { forceValue } from '../optional';
import { Parity, ParityTwist, DoubleSwap, Twist } from './alg';
import { BufferState } from './buffer-state';
import { TwistWithCost } from './twist-with-cost';
import { PiecePermutationDescription } from './piece-permutation-description';
import { PieceMethodDescription } from './method-description';

// Responsible for making decisions during the solve, e.g. which buffer we should use net.
// Interprets the method description to make these decisions.
export class Decider {
  readonly twistsWithCosts: TwistWithCost[];
  readonly sortedBuffers: readonly Piece[];

  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              private readonly methodDescription: PieceMethodDescription) {
    this.twistsWithCosts = piecePermutationDescription.pieceDescription.twistGroups().filter(g => {
      const allowedAsFloatingTwist = g.numUnoriented <= this.methodDescription.maxFloatingTwistLength
      const allowedAsBufferedTwist = g.orientedTypes.some((orientedType, index) => {
        return !orientedType.isSolved &&
          this.methodDescription.sortedBufferDescriptions.some(b => b.maxTwistLength >= g.numUnoriented && b.buffer.pieceId === index);
      });
      return allowedAsFloatingTwist || allowedAsBufferedTwist;
    }).map(g => {
      return {twist: new Twist(g.orientedTypes), cost: 1};
    });
    this.sortedBuffers = this.methodDescription.sortedBufferDescriptions.map(d => d.buffer);
  }

  private bufferDescription(buffer: Piece) {
    return forceValue(find(this.methodDescription.sortedBufferDescriptions, b => b.buffer.pieceId === buffer.pieceId));
  }

  sortedNextCycleBreaksOnSecondPiece(buffer: Piece, firstPiece: Piece): readonly Piece[] {
    return this.piecePermutationDescription.pieces;
  }

  sortedNextCycleBreaksOnFirstPiece(buffer: Piece): readonly Piece[] {
    return this.piecePermutationDescription.pieces;
  }

  // Pieces that can be twisted in combination with the given parity. Sorted by priority.
  sortedParityTwistUnorientedsForParity(parity: Parity): readonly Piece[] {
    if (!this.bufferDescription(parity.firstPiece).canDoParityTwists) {
      return [];
    }
    return this.piecePermutationDescription.pieces;
  }

  // Stay with this buffer if all buffers are solved.
  // If false, will switch back to the main buffer instead.
  stayWithSolvedBuffer(buffer: Piece) {
    return this.bufferDescription(buffer).stayWithSolvedBuffer;
  }

  canChangeBuffer(bufferState: BufferState) {
    return bufferState.cycleBreaks === 0;
  }

  canDoubleSwap(doubleSwap: DoubleSwap) {
    return false;
  }

  get avoidUnorientedIfWeCanFloat() {
    return this.methodDescription.avoidUnorientedIfWeCanFloat;
  }

  doUnorientedBeforeParity(parity: Parity, unoriented: Piece) {
    return true;
  }

  doUnorientedBeforeParityTwist(parityTwist: ParityTwist, unoriented: Piece) {
    return true;
  }

  maxCycleLengthForBuffer(buffer: Piece) {
    return this.bufferDescription(buffer).fiveCycles ? 5 : 3;
  }
}
