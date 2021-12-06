import { orElseCall, mapOptional } from '../optional';
import { minBy, first } from '../utils';
import { assert } from '../assert';
import { Piece } from './piece';
import { Parity, ThreeCycle, EvenCycle, ParityTwist, DoubleSwap } from './alg';
import { ScrambleGroup, ProbabilisticAnswer, deterministicAnswer, PartiallyFixedOrientedType } from './scramble-group';
import { Probabilistic } from './probabilistic';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { AlgCounts } from './alg-counts';
import { Decider } from './decider';
import { BufferState, emptyBufferState, newBufferState } from './buffer-state';

type ProbabilisticAlgTrace = ProbabilisticAnswer<AlgTrace>;

export class Solver {
  constructor(readonly decider: Decider, readonly pieces: Piece[]) {}

  get orderedBuffers() {
    return this.pieces.filter(piece => this.decider.isBuffer(piece)).sort((left, right) => this.decider.bufferPriority(right) - this.decider.bufferPriority(left));
  }

  get favoriteBuffer() {
    return this.orderedBuffers[0];
  }
  
  private nextBufferAvoidingSolved(bufferState: BufferState, group: ScrambleGroup): Piece {
    const unsolvedBuffer = first(this.orderedBuffers.filter(piece => !group.isSolved(piece)));
    return orElseCall(unsolvedBuffer, () => {
      const previousBuffer = bufferState.previousBuffer;
      if (previousBuffer && this.decider.stayWithSolvedBuffer(previousBuffer)) {
        return previousBuffer;
      } else {
        return this.favoriteBuffer;
      }
    });
  }

  private nextBufferAvoidingUnoriented(bufferState: BufferState, group: ScrambleGroup): Piece {
    const permutedBuffer = first(this.orderedBuffers.filter(buffer => group.isPermuted(buffer)));
    return orElseCall(permutedBuffer, () => this.nextBufferAvoidingSolved(bufferState, group));
  }

  private nextBuffer(bufferState: BufferState, group: ScrambleGroup): Piece {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return previousBuffer;
    }
    if (this.decider.avoidUnorientedIfWeCanFloat) {
      return this.nextBufferAvoidingUnoriented(bufferState, group);
    } else {
      return this.nextBufferAvoidingSolved(bufferState, group);
    }
  }

  private algsWithVanillaParity(bufferState: BufferState, group: ScrambleGroup, parity: Parity): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (group.unoriented.length === 1) {
      const unoriented = group.unoriented[0];
      if (this.decider.doUnorientedBeforeParity(parity, unoriented)) {
        const cycleBreak = new ThreeCycle(parity.firstPiece, parity.lastPiece, unoriented);
        const remainingGroup = group.breakCycleFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak();
        const newParity = new Parity(parity.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingGroup, newParity);
        return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
      }
    }
    return group.orientedTypeForPieces(parity.pieces).flatMap((group, orientedType) => {
      return this.algsWithVanillaParityWithOrientedType(bufferState, group, parity, orientedType);
    });
  }

  private algsWithVanillaParityWithOrientedType(bufferState: BufferState, group: ScrambleGroup, parity: Parity, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {  
    const remainingGroup = group.solveParity(parity, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixParity(parity));
  }

  private algsWithParityTwist(bufferState: BufferState, group: ScrambleGroup, parityTwist: ParityTwist): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (group.unoriented.length === 1) {
      const unoriented = group.unoriented[0];
      if (this.decider.doUnorientedBeforeParityTwist(parityTwist, unoriented)) {
        const cycleBreak = new ThreeCycle(parityTwist.firstPiece, parityTwist.lastPiece, unoriented);
        const remainingGroup = group.breakCycleFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak();
        const newParity = new Parity(parityTwist.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingGroup, newParity);
        return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
      }
    }
    return group.orientedTypeForPieces(parityTwist.swappedPieces).flatMap((group, orientedType) => {
      return this.algsWithParityTwistWithOrientedType(bufferState, group, parityTwist, orientedType);
    });
  }

  private algsWithParityTwistWithOrientedType(bufferState: BufferState, group: ScrambleGroup, parityTwist: ParityTwist, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingGroup = group.solveParityTwist(parityTwist, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixParityTwist(parityTwist));
  };

  private algsWithParity(bufferState: BufferState, group: ScrambleGroup, parity: Parity): ProbabilisticAlgTrace {
    const buffer = parity.firstPiece;
    const otherPiece = parity.lastPiece;
    const parityTwistPieces = group.unoriented.filter(piece => this.decider.canParityTwist(new ParityTwist(buffer, otherPiece, piece)));
    const parityTwists = parityTwistPieces.map(piece => new ParityTwist(buffer, otherPiece, piece));
    const maybeParityTwist = minBy(parityTwists, parityTwist => this.decider.parityTwistPriority(parityTwist));
    return orElseCall(mapOptional(maybeParityTwist, parityTwist => this.algsWithParityTwist(bufferState, group, parityTwist)),
                      () => this.algsWithVanillaParity(bufferState, group, parity));
  }

  private algsWithPartialDoubleSwap(bufferState: BufferState, group: ScrambleGroup, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    const remainingGroup = group.partiallySolveDoubleSwap(doubleSwap);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixDoubleSwap(doubleSwap));
  }

  private algsWithSolvedDoubleSwap(bufferState: BufferState, group: ScrambleGroup, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    return group.orientedTypeForPieces([doubleSwap.thirdPiece, doubleSwap.fourthPiece]).flatMap((group, orientedType) => {
      return this.algsWithSolvedDoubleSwapAndOrientedType(bufferState, group, doubleSwap, orientedType);
    });
  }

  private algsWithSolvedDoubleSwapAndOrientedType(bufferState: BufferState, group: ScrambleGroup, doubleSwap: DoubleSwap, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingGroup = group.solveDoubleSwap(doubleSwap, orientedType);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixDoubleSwap(doubleSwap));
  }

  private algsWithDoubleSwap(bufferState: BufferState, group: ScrambleGroup, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    if (group.cycleLength(doubleSwap.thirdPiece).assertDeterministicAnswer() === 2) {
      return this.algsWithSolvedDoubleSwap(bufferState, group, doubleSwap);
    } else {
      return this.algsWithPartialDoubleSwap(bufferState, group, doubleSwap);
    }
  }

  private algsWithCycleBreakFromSwap(bufferState: BufferState, group: ScrambleGroup, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.breakCycleFromSwap(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
  }

  private algsWithCycleBreakFromUnpermuted(bufferState: BufferState, group: ScrambleGroup, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.breakCycleFromUnpermuted(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
  }

  private algsWithEvenCycle(bufferState: BufferState, group: ScrambleGroup, cycle: EvenCycle): ProbabilisticAlgTrace {
    return group.orientedTypeForPieces(cycle.pieces).flatMap((group, orientedType) => {
      return this.algsWithEvenCycleWithOrientedType(bufferState, group, cycle, orientedType);
    });
  }
  
  private algsWithEvenCycleWithOrientedType(bufferState: BufferState, group: ScrambleGroup, cycle: EvenCycle, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingGroup = group.solveEvenCycle(cycle, orientedType);
    const remainingTraces = this.algs(bufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixEvenCycle(cycle));
  }

  private unorientedAlgs(group: ScrambleGroup): ProbabilisticAlgTrace {
    assert(!group.hasPermuted, 'unorienteds cannot permute');
    switch(group.unorientedTypes) {
      case 0:
        return deterministicAnswer(group, emptyAlgTrace());
      default:
        assert(false, 'more than 2 types of unoriented aren not supported yet')
    }
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState: BufferState, group: ScrambleGroup, buffer: Piece, otherPiece: Piece, cycleBreak: Piece, nextPiece: Piece): ProbabilisticAlgTrace {
    const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(doubleSwap)) {
      return this.algsWithDoubleSwap(bufferState, group, doubleSwap);
    }
    return this.algsWithCycleBreakFromSwap(bufferState, group, new ThreeCycle(buffer, otherPiece, cycleBreak));
  }

  private cycleBreakWithBufferAndOtherPiece(bufferState: BufferState, group: ScrambleGroup, buffer: Piece, otherPiece: Piece): ProbabilisticAlgTrace {
    const cycleBreak = this.decider.nextCycleBreakOnSecondPiece(buffer, otherPiece, group.permuted.filter(piece => piece !== buffer && piece !== otherPiece));
    return group.nextPiece(cycleBreak).flatMap((group, nextPiece) => this.cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState, group, buffer, otherPiece, cycleBreak, nextPiece));
  }

  private algsWithPartialCycle(bufferState: BufferState, group: ScrambleGroup, cycle: EvenCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.solvePartialEvenCycle(cycle);
    const remainingTraces = this.algs(bufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixEvenCycle(cycle));
  }

  private algsWithBufferAndCycleLength(bufferState: BufferState, group: ScrambleGroup, buffer: Piece, cycleLength: number): ProbabilisticAlgTrace {
    if (cycleLength === 2) {
      if (group.parityTime) {
        const otherPiece = group.nextPiece(buffer).assertDeterministicAnswer();
        return this.algsWithParity(bufferState, group, new Parity(buffer, otherPiece));
      } else {
        return group.nextPiece(buffer).flatMap((group, otherPiece) => this.cycleBreakWithBufferAndOtherPiece(bufferState, group, buffer, otherPiece));
      }
    } else if (cycleLength % 2 === 0) {
      return group.unsortedPiecesInCycle(buffer).flatMap((group, pieces) => this.algsWithEvenCycle(bufferState, group, new EvenCycle(pieces)));
    } else {
      return group.evenPermutationCyclePart(buffer).flatMap((group, pieces) => {
        return this.algsWithPartialCycle(bufferState, group, new EvenCycle(pieces));
      });
    }
  }
  
  private algs(bufferState: BufferState, group: ScrambleGroup): ProbabilisticAlgTrace {
    const buffer = this.nextBuffer(bufferState, group);
    if (buffer !== bufferState.previousBuffer) {
      bufferState = emptyBufferState();
    }
    if (group.isSolved(buffer) && group.hasPermuted) {
      const cycleBreakPiece = this.decider.nextCycleBreakOnFirstPiece(buffer, group.permuted.filter(piece => piece !== buffer));
      return group.nextPiece(cycleBreakPiece).flatMap((group, nextPiece) => {
        return this.algsWithCycleBreakFromUnpermuted(bufferState, group, new ThreeCycle(buffer, cycleBreakPiece, nextPiece));
      });
    } else if (group.isPermuted(buffer)) {
      return group.cycleLength(buffer).flatMap((group, cycleLength) => {
        return this.algsWithBufferAndCycleLength(bufferState, group, buffer, cycleLength);
      });
    } else if (group.hasUnoriented) {
      return this.unorientedAlgs(group);
    } else {
      return deterministicAnswer(group, emptyAlgTrace());
    }
  }

  algCounts(group: ScrambleGroup): Probabilistic<AlgCounts> {
    return this.algs(emptyBufferState(), group).removeGroups().map(algTrace => algTrace.withMaxCycleLength(this.decider.maxCycleLength).countAlgs());
  }
}
