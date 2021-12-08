import { orElseCall, mapOptional } from '../optional';
import { minBy, first } from '../utils';
import { assert } from '../assert';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { Parity, ThreeCycle, EvenCycle, ParityTwist, DoubleSwap, Alg } from './alg';
import { Solvable, ProbabilisticAnswer, deterministicAnswer, PartiallyFixedOrientedType } from './solvable';
import { Probabilistic } from './probabilistic';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { AlgCounts } from './alg-counts';
import { Decider } from './decider';
import { BufferState, emptyBufferState, newBufferState } from './buffer-state';
import { TwistSolver, createTwistSolver } from './twist-solver';

type ProbabilisticAlgTrace = ProbabilisticAnswer<AlgTrace>;

function withPrefix(algTraces: ProbabilisticAlgTrace, alg: Alg): ProbabilisticAlgTrace {
  return algTraces.mapAnswer(trace => trace.withPrefix(alg));
}

export class Solver {
  constructor(readonly decider: Decider, readonly pieces: Piece[], readonly twistSolver: TwistSolver) {}

  get orderedBuffers() {
    return this.pieces.filter(piece => this.decider.isBuffer(piece)).sort((left, right) => this.decider.bufferPriority(right) - this.decider.bufferPriority(left));
  }

  get favoriteBuffer() {
    return this.orderedBuffers[0];
  }

  private nextBufferAvoidingSolved(bufferState: BufferState, solvable: Solvable): Piece {
    const unsolvedBuffer = first(this.orderedBuffers.filter(piece => !solvable.isSolved(piece)));
    return orElseCall(unsolvedBuffer, () => {
      const previousBuffer = bufferState.previousBuffer;
      if (previousBuffer && this.decider.stayWithSolvedBuffer(previousBuffer)) {
        return previousBuffer;
      } else {
        return this.favoriteBuffer;
      }
    });
  }

  private nextBufferAvoidingUnoriented(bufferState: BufferState, solvable: Solvable): Piece {
    const permutedBuffer = first(this.orderedBuffers.filter(buffer => solvable.isPermuted(buffer)));
    return orElseCall(permutedBuffer, () => this.nextBufferAvoidingSolved(bufferState, solvable));
  }

  private nextBuffer(bufferState: BufferState, solvable: Solvable): Piece {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return previousBuffer;
    }
    if (this.decider.avoidUnorientedIfWeCanFloat) {
      return this.nextBufferAvoidingUnoriented(bufferState, solvable);
    } else {
      return this.nextBufferAvoidingSolved(bufferState, solvable);
    }
  }

  private algsWithVanillaParity(bufferState: BufferState, solvable: Solvable, parity: Parity): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (solvable.unoriented.length === 1) {
      const unoriented = solvable.unoriented[0];
      if (this.decider.doUnorientedBeforeParity(parity, unoriented)) {
        const cycleBreak = new ThreeCycle(parity.firstPiece, parity.lastPiece, unoriented);
        const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak();
        const newParity = new Parity(parity.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingSolvable, newParity);
        return withPrefix(remainingTraces, cycleBreak);
      }
    }
    return solvable.decideOrientedTypeForPieces(parity.pieces).flatMap((solvable, orientedType) => {
      return this.algsWithVanillaParityWithOrientedType(bufferState, solvable, parity, orientedType);
    });
  }

  private algsWithVanillaParityWithOrientedType(bufferState: BufferState, solvable: Solvable, parity: Parity, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyParity(parity, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parity);
  }

  private algsWithParityTwist(bufferState: BufferState, solvable: Solvable, parityTwist: ParityTwist): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (solvable.unoriented.length === 1) {
      const unoriented = solvable.unoriented[0];
      if (this.decider.doUnorientedBeforeParityTwist(parityTwist, unoriented)) {
        const cycleBreak = new ThreeCycle(parityTwist.firstPiece, parityTwist.lastPiece, unoriented);
        const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
        const nextBufferState = bufferState.withCycleBreak();
        const newParity = new Parity(parityTwist.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(nextBufferState, remainingSolvable, newParity);
        return withPrefix(remainingTraces, cycleBreak);
      }
    }
    return solvable.decideOrientedTypeForPieces(parityTwist.swappedPieces).flatMap((solvable, orientedType) => {
      return this.algsWithParityTwistWithOrientedType(bufferState, solvable, parityTwist, orientedType);
    });
  }

  private algsWithParityTwistWithOrientedType(bufferState: BufferState, solvable: Solvable, parityTwist: ParityTwist, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyParityTwist(parityTwist, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parityTwist);
  };

  private algsWithParity(bufferState: BufferState, solvable: Solvable, parity: Parity): ProbabilisticAlgTrace {
    const buffer = parity.firstPiece;
    const otherPiece = parity.lastPiece;
    const parityTwistPieces = solvable.unoriented.filter(piece => this.decider.canParityTwist(new ParityTwist(buffer, otherPiece, piece)));
    const parityTwists = parityTwistPieces.map(piece => new ParityTwist(buffer, otherPiece, piece));
    const maybeParityTwist = minBy(parityTwists, parityTwist => this.decider.parityTwistPriority(parityTwist));
    return orElseCall(mapOptional(maybeParityTwist, parityTwist => this.algsWithParityTwist(bufferState, solvable, parityTwist)),
                      () => this.algsWithVanillaParity(bufferState, solvable, parity));
  }

  private algsWithPartialDoubleSwap(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyPartialDoubleSwap(doubleSwap);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable);
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithSolvedDoubleSwap(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    return solvable.decideOrientedTypeForPieces([doubleSwap.thirdPiece, doubleSwap.fourthPiece]).flatMap((solvable, orientedType) => {
      return this.algsWithSolvedDoubleSwapAndOrientedType(bufferState, solvable, doubleSwap, orientedType);
    });
  }

  private algsWithSolvedDoubleSwapAndOrientedType(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applySolvedDoubleSwap(doubleSwap, orientedType);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable);
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithDoubleSwap(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    if (solvable.decideCycleLength(doubleSwap.thirdPiece).assertDeterministicAnswer() === 2) {
      return this.algsWithSolvedDoubleSwap(bufferState, solvable, doubleSwap);
    } else {
      return this.algsWithPartialDoubleSwap(bufferState, solvable, doubleSwap);
    }
  }

  private algsWithCycleBreakFromSwap(bufferState: BufferState, solvable: Solvable, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithCycleBreakFromUnpermuted(bufferState: BufferState, solvable: Solvable, cycleBreak: ThreeCycle): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyCycleBreakFromUnpermuted(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithEvenCycle(bufferState: BufferState, solvable: Solvable, cycle: EvenCycle): ProbabilisticAlgTrace {
    return solvable.decideOrientedTypeForPieces(cycle.pieces).flatMap((solvable, orientedType) => {
      return this.algsWithEvenCycleWithOrientedType(bufferState, solvable, cycle, orientedType);
    });
  }

  private algsWithEvenCycleWithOrientedType(bufferState: BufferState, solvable: Solvable, cycle: EvenCycle, orientedType: PartiallyFixedOrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyCompleteEvenCycle(cycle, orientedType);
    const remainingTraces = this.algs(bufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycle);
  }

  private unorientedAlgs(solvable: Solvable): ProbabilisticAlgTrace {
    assert(!solvable.hasPermuted, 'unorienteds cannot permute');
    return new ProbabilisticAnswer<AlgTrace>(this.twistSolver.algs(solvable.unorientedByType).map(algs => [solvable, algs]));
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState: BufferState, solvable: Solvable, buffer: Piece, otherPiece: Piece, cycleBreak: Piece, nextPiece: Piece): ProbabilisticAlgTrace {
    const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(doubleSwap)) {
      return this.algsWithDoubleSwap(bufferState, solvable, doubleSwap);
    }
    return this.algsWithCycleBreakFromSwap(bufferState, solvable, new ThreeCycle(buffer, otherPiece, cycleBreak));
  }

  private cycleBreakWithBufferAndOtherPiece(bufferState: BufferState, solvable: Solvable, buffer: Piece, otherPiece: Piece): ProbabilisticAlgTrace {
    const cycleBreak = this.decider.nextCycleBreakOnSecondPiece(buffer, otherPiece, solvable.permuted.filter(piece => piece !== buffer && piece !== otherPiece));
    return solvable.decideNextPiece(cycleBreak).flatMap((solvable, nextPiece) => this.cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState, solvable, buffer, otherPiece, cycleBreak, nextPiece));
  }

  private algsWithPartialCycle(bufferState: BufferState, solvable: Solvable, cycle: EvenCycle): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyPartialEvenCycle(cycle);
    const remainingTraces = this.algs(bufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycle);
  }

  private algsWithBufferAndCycleLength(bufferState: BufferState, solvable: Solvable, buffer: Piece, cycleLength: number): ProbabilisticAlgTrace {
    if (cycleLength === 2) {
      if (solvable.parityTime) {
        const otherPiece = solvable.decideNextPiece(buffer).assertDeterministicAnswer();
        return this.algsWithParity(bufferState, solvable, new Parity(buffer, otherPiece));
      } else {
        return solvable.decideNextPiece(buffer).flatMap((solvable, otherPiece) => this.cycleBreakWithBufferAndOtherPiece(bufferState, solvable, buffer, otherPiece));
      }
    } else if (cycleLength % 2 === 1) {
      return solvable.decideUnsortedOtherPiecesInCycle(buffer).flatMap((solvable, unsortedLastPieces) => {
        assert(unsortedLastPieces.length % 2 === 0, 'uneven completed cycle');
        return this.algsWithEvenCycle(bufferState, solvable, new EvenCycle(buffer, unsortedLastPieces.length));
      });
    } else {
      return solvable.decideUnsortedOtherPiecesInEvenPermutationCyclePart(buffer).flatMap((solvable, unsortedLastPieces) => {
        assert(unsortedLastPieces.length === cycleLength - 2);
        assert(unsortedLastPieces.length % 2 === 0, 'uneven partial cycle');
        return this.algsWithPartialCycle(bufferState, solvable, new EvenCycle(buffer, unsortedLastPieces.length));
      });
    }
  }

  private algs(bufferState: BufferState, solvable: Solvable): ProbabilisticAlgTrace {
    const buffer = this.nextBuffer(bufferState, solvable);
    if (buffer !== bufferState.previousBuffer) {
      bufferState = emptyBufferState();
    }
    if (solvable.isSolved(buffer) && solvable.hasPermuted) {
      const cycleBreakPiece = this.decider.nextCycleBreakOnFirstPiece(buffer, solvable.permuted.filter(piece => piece !== buffer));
      return solvable.decideNextPiece(cycleBreakPiece).flatMap((solvable, nextPiece) => {
        return this.algsWithCycleBreakFromUnpermuted(bufferState, solvable, new ThreeCycle(buffer, cycleBreakPiece, nextPiece));
      });
    } else if (solvable.isPermuted(buffer)) {
      return solvable.decideCycleLength(buffer).flatMap((solvable, cycleLength) => {
        return this.algsWithBufferAndCycleLength(bufferState, solvable, buffer, cycleLength);
      });
    } else if (solvable.hasUnoriented) {
      return this.unorientedAlgs(solvable);
    } else {
      return deterministicAnswer(solvable, emptyAlgTrace());
    }
  }

  algCounts(solvable: Solvable): Probabilistic<AlgCounts> {
    return this.algs(emptyBufferState(), solvable).removeSolvables().map(algTrace => algTrace.withMaxCycleLength(buffer => this.decider.maxCycleLengthForBuffer(buffer)).countAlgs());
  }
}

export function createSolver(decider: Decider, pieceDescription: PieceDescription) {
  return new Solver(decider, pieceDescription.pieces, createTwistSolver(pieceDescription, decider.twistsWithCosts));
}
