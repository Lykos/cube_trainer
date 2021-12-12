import { Piece } from './piece';
import { OrientedType } from './oriented-type';
import { find } from '../utils';
import { forceValue } from '../optional';
import { Parity, ParityTwist, DoubleSwap, Twist } from './alg';
import { BufferState } from './buffer-state';
import { TwistWithCost } from './twist-with-cost';
import { PiecePermutationDescription } from './piece-permutation-description';
import { PieceMethodDescription, HierarchicalAlgSet, UniformAlgSet, UniformAlgSetMode } from './method-description';

function orientedCompatible(algSet: UniformAlgSet, orientedType: OrientedType) {
  return algSet.mode === UniformAlgSetMode.ALL || algSet.mode === UniformAlgSetMode.ONLY_ORIENTED && orientedType.isSolved;
}

function hasOrientedHierarchicalAlg1(algSet: HierarchicalAlgSet<UniformAlgSet>,
                                     firstPiece: Piece, orientedType: OrientedType) {
  switch (algSet.tag) {
    case 'uniform':
      return orientedCompatible(algSet, orientedType);
    case 'partial':
      return algSet.subsets.some(subset => subset.piece.pieceId === firstPiece.pieceId && orientedCompatible(subset.subset, orientedType));
  }
}

function hasOrientedHierarchicalAlg2(algSet: HierarchicalAlgSet<HierarchicalAlgSet<UniformAlgSet>>,
                                     firstPiece: Piece, secondPiece: Piece, orientedType: OrientedType) {
  switch (algSet.tag) {
    case 'uniform':
      return orientedCompatible(algSet, orientedType);
    case 'partial':
      return algSet.subsets.some(subset => subset.piece.pieceId === firstPiece.pieceId && hasOrientedHierarchicalAlg1(subset.subset, secondPiece, orientedType));
  }
}

function hasOrientedHierarchicalAlg3(algSet: HierarchicalAlgSet<HierarchicalAlgSet<HierarchicalAlgSet<UniformAlgSet>>>,
                                     firstPiece: Piece, secondPiece: Piece, thirdPiece: Piece, orientedType: OrientedType) {
  switch (algSet.tag) {
    case 'uniform':
      return orientedCompatible(algSet, orientedType);
    case 'partial':
      return algSet.subsets.some(subset => subset.piece.pieceId === firstPiece.pieceId && hasOrientedHierarchicalAlg2(subset.subset, secondPiece, thirdPiece, orientedType));
  }
}

function hasOrientedHierarchicalAlg4(algSet: HierarchicalAlgSet<HierarchicalAlgSet<HierarchicalAlgSet<HierarchicalAlgSet<UniformAlgSet>>>>,
                                     firstPiece: Piece, secondPiece: Piece, thirdPiece: Piece, fourthPiece: Piece, orientedType: OrientedType) {
  switch (algSet.tag) {
    case 'uniform':
      return orientedCompatible(algSet, orientedType);
    case 'partial':
      return algSet.subsets.some(subset => subset.piece.pieceId === firstPiece.pieceId && hasOrientedHierarchicalAlg3(subset.subset, secondPiece, thirdPiece, fourthPiece, orientedType));
  }
}

// Responsible for making decisions during the solve, e.g. which buffer we should use net.
// Interprets the method description to make these decisions.
export class Decider {
  readonly twistsWithCosts: TwistWithCost[];
  readonly sortedBuffers: readonly Piece[];
  readonly sortedCycleBreaks: readonly Piece[];

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
    if (this.methodDescription.avoidBuffersForCycleBreaks) {
      const nonBuffers = this.piecePermutationDescription.pieces.filter(p => !this.sortedBuffers.some(b => b.pieceId === p.pieceId));
      this.sortedCycleBreaks = nonBuffers.concat([...this.sortedBuffers].reverse());
    } else {
      this.sortedCycleBreaks = this.piecePermutationDescription.pieces;
    }
  }

  private bufferDescription(buffer: Piece) {
    return forceValue(find(this.methodDescription.sortedBufferDescriptions, b => b.buffer.pieceId === buffer.pieceId));
  }

  sortedNextCycleBreaksOnSecondPiece(buffer: Piece, firstPiece: Piece): readonly Piece[] {
    return this.sortedCycleBreaks;
  }

  sortedNextCycleBreaksOnFirstPiece(buffer: Piece): readonly Piece[] {
    return this.sortedCycleBreaks;
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

  canDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType) {
    return hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.firstPiece, doubleSwap.thirdPiece, doubleSwap.secondPiece, doubleSwap.fourthPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.firstPiece, doubleSwap.thirdPiece, doubleSwap.fourthPiece, doubleSwap.secondPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.thirdPiece, doubleSwap.firstPiece, doubleSwap.secondPiece, doubleSwap.fourthPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.thirdPiece, doubleSwap.firstPiece, doubleSwap.fourthPiece, doubleSwap.secondPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.secondPiece, doubleSwap.fourthPiece, doubleSwap.firstPiece, doubleSwap.thirdPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.fourthPiece, doubleSwap.secondPiece, doubleSwap.firstPiece, doubleSwap.thirdPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.secondPiece, doubleSwap.fourthPiece, doubleSwap.thirdPiece, doubleSwap.firstPiece, orientedType) ||
      hasOrientedHierarchicalAlg4(this.methodDescription.doubleSwaps, doubleSwap.fourthPiece, doubleSwap.secondPiece, doubleSwap.thirdPiece, doubleSwap.firstPiece, orientedType);
  }

  get avoidUnorientedIfWeCanFloat() {
    return this.methodDescription.avoidUnorientedIfWeCanFloat;
  }

  doUnorientedBeforeParity(parity: Parity, unoriented: Piece) {
    return this.bufferDescription(parity.firstPiece).doUnorientedBeforeParity;
  }

  doUnorientedBeforeParityTwist(parityTwist: ParityTwist, unoriented: Piece) {
    return this.bufferDescription(parityTwist.firstPiece).doUnorientedBeforeParityTwist;
  }

  maxCycleLengthForBuffer(buffer: Piece) {
    return this.bufferDescription(buffer).fiveCycles ? 5 : 3;
  }
}
