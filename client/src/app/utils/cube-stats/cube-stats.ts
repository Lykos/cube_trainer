import { some, none, Optional, orElseCall, mapOptional } from './optional';
import { sum, minBy } from './utils';
import { assert } from './assert';
import { Piece } from './piece';
import { Parity, ThreeCycle, EvenCycle, ParityTwist, DoubleSwap } from './alg';
import { ProbabilisticAnswer, ScrambleGroup } from './scramble-group';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { Decider } from './decider';
import { BufferState } from './buffer-state';

function first<X>(xs: X[]): Optional<X> {
  if (xs.length >= 1) {
    return some(xs[0]);
  } else {
    return none;
  }
}

type ProbabilisticAlgTrace = ProbabilisticAnswer<AlgTrace>;

class Solver {
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

  algsWithVanillaParity(bufferState: BufferState, group: ScrambleGroup, parity: Parity): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    const flatUnoriented = group.unoriented.flat(1);
    if (flatUnoriented.length === 1) {
      const unoriented = flatUnoriented[0];
      if (this.decider.doUnorientedBeforeParity(parity, unoriented)) {
        const cycleBreak = new ThreeCycle(parity.firstPiece, parity.lastPiece, unoriented);
        const remainingGroup = group.breakCycleFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak(cycleBreak);
        const newParity = new Parity(parity.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingGroup, newParity);
        return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
      }
    }
    const remainingGroup = group.solveParity(parity);
    const nextBufferState = bufferState.withParity(parity);
    const remainingTraces = this.unorientedAlgs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixParity(parity));
  }

  algsWithParityTwist(bufferState: BufferState, group: ScrambleGroup, parityTwist: ParityTwist) {
    // If they want to do one other unoriented first, that can be done.
    const flatUnoriented = group.unoriented.flat(1);
    if (flatUnoriented.length === 1) {
      const unoriented = flatUnoriented[0];
      if (this.decider.doUnorientedBeforeParityTwist(parityTwist, unoriented)) {
        const cycleBreak = new ThreeCycle(parityTwist.firstPiece, parityTwist.lastPiece, unoriented);
        const remainingGroup = group.breakCycleFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak(cycleBreak);
        const newParity = new Parity(parityTwist.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingGroup, newParity);
        return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
      }
    }
    const nextBufferState = bufferState.withParityTwist(parityTwist);
    const remainingGroup = group.solveParityTwist(parityTwist);
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixParityTwist(parityTwist));
  }

  algsWithParity(bufferState: BufferState, group: ScrambleGroup, parity: Parity): ProbabilisticAlgTrace {
    const buffer = parity.firstPiece;
    const otherPiece = parity.lastPiece;
    const parityTwistPieces = group.unorientedForInverseType(parity).filter(piece => this.decider.canParityTwist(new ParityTwist(buffer, otherPiece, piece)));
    const parityTwists = parityTwistPieces.map(piece => new ParityTwist(buffer, otherPiece, piece));
    const maybeParityTwist = minBy(parityTwists, parityTwist => this.decider.parityTwistPriority(parityTwist));
    return orElseCall(mapOptional(maybeParityTwist, parityTwist => this.algsWithParityTwist(bufferState, group, parityTwist)),
                      () => this.algsWithVanillaParity(bufferState, group, parity));
  }

  algsWithDoubleSwap(bufferState: BufferState, group: ScrambleGroup, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    const remainingGroup = group.solveDoubleSwap(doubleSwap);
    const nextBufferState = bufferState.withSwap(doubleSwap.thirdPiece, doubleSwap.fourthPiece);
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixDoubleSwap(doubleSwap));
  }

  algsWithCycleBreakFromSwap(bufferState: BufferState, group: ScrambleGroup, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.breakCycleFromSwap(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak(cycleBreak);
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
  }

  algsWithCycleBreakFromUnpermuted(bufferState: BufferState, group: ScrambleGroup, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.breakCycleFromUnpermuted(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak(cycleBreak);
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixThreeCycle(cycleBreak));
  }

  algsWithEvenCycle(bufferState: BufferState, group: ScrambleGroup, cycle: EvenCycle): ProbabilisticAlgTrace {
    const remainingGroup = group.solveEvenCycle(cycle);
    const nextBufferState = bufferState.withEvenCycle(cycle);
    const remainingTraces = this.algs(nextBufferState, remainingGroup);
    return remainingTraces.mapAnswer(remainingTrace => remainingTrace.prefixEvenCycle(cycle));
  }

  private unorientedAlgs(bufferState: BufferState, group: ScrambleGroup): ProbabilisticAlgTrace {
    assert(!group.hasPermuted, 'Unorienteds cannot permute');
    // TODO
    assert(false);
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState: BufferState, group: ScrambleGroup, buffer: Piece, otherPiece: Piece, cycleBreak: Piece, nextPiece: Piece): ProbabilisticAlgTrace {
    const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(doubleSwap)) {
      return this.algsWithDoubleSwap(bufferState, group, doubleSwap);
    }
    return this.algsWithCycleBreakFromSwap(bufferState, group, new ThreeCycle(buffer, otherPiece, cycleBreak));
  }

  private cycleBreakWithBufferAndOtherPiece(bufferState: BufferState, group: ScrambleGroup, buffer: Piece, otherPiece: Piece): ProbabilisticAlgTrace {
    const cycleBreak = this.decider.nextCycleBreakOnSecondPiece(buffer, otherPiece, group.permuted);
    return group.nextPiece(cycleBreak).flatMap((group, nextPiece) => this.cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState, group, buffer, otherPiece, cycleBreak, nextPiece));
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
        return this.algsWithPartialCycle(bufferState, group, evenPermutationCycle, new EvenCycle(pieces));
      });
    }
  }
  
  private algs(bufferState: BufferState, group: ScrambleGroup): ProbabilisticAlgTrace {
    const buffer = this.nextBuffer();
    if (group.isSolved(buffer) && group.hasPermuted) {
      const cycleBreakPiece = this.decider.nextCycleBreakOnFirstPiece(buffer, group.permutedPieces);
      return group.nextPiece(cycleBreakPiece).flatMap((group, nextPiece) => {
        return this.algsWithCycleBreakFromUnpermuted(bufferState, group, new ThreeCycle(buffer, cycleBreakPiece, nextPiece));
      });
    } else if (group.isPermuted(buffer)) {
      group.cycleLength(buffer).flatMap((group, cycleLength) => {
        return this.algsWithBufferAndCycleLength(bufferState, group, buffer, cycleLength);
      });
    }
  } else if (group.hasUnorienteds) {
    return this.unorientedAlgs();
  } else {
    assert(group.isSolved, 'Nothing to do but not solved');
    return emptyAlgTrace();
  }
}

class SolvingMethod {
  constructor(readonly piecePermutationDescription: PiecePermutationDescription,
              readonly piece: Piece[]) {
    assert(buffers >= 1, 'There has to be at least one buffer');
  }

  expectedAlgs(): number {
    const groups = this.piecePermutationDescription.groups();
    const directComputed = this.piecePermutationDescription.count;
    const groupSum = sum(groups.map(group => group.count()));
    assert(Math.round(directComputed) === Math.round(groupSum), `${directComputed} === ${groupSum} (direct computed vs group sum)`)
    return sum(groups.map(group => {
      const probability = group.count() / this.piecePermutationDescription.count;
      const algsForGroup = new SolveState(group, this.pieces).algs();
      return probability * algsForGroup;
    }));
  }

  importantGroup(group: PermutationGroup) {
    const probability = group.count() / this.piecePermutationDescription.count;
    return probability > 0.01;
  }
}

export enum ExecutionOrder {
  CE, EC
}

export interface MethodDescription {
  readonly executionOrder: ExecutionOrder;
}

export function expectedAlgs(methodDescription: MethodDescription): number {
  switch (methodDescription.executionOrder) {
    case ExecutionOrder.EC:
      return new SolvingMethod(new PiecePermutationDescription(EDGE, false), 1).expectedAlgs() +
        new SolvingMethod(new PiecePermutationDescription(CORNER, true), 1).expectedAlgs();
    case ExecutionOrder.CE:
      return new SolvingMethod(new PiecePermutationDescription(CORNER, false), 1).expectedAlgs() +
        new SolvingMethod(new PiecePermutationDescription(EDGE, true), 1).expectedAlgs();
  }
}
