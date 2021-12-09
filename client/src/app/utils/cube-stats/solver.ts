import { orElseCall, mapOptional } from '../optional';
import { minBy } from '../utils';
import { assert } from '../assert';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { Parity, ThreeCycle, EvenCycle, DoubleSwap, Alg } from './alg';
import { Solvable, OrientedType } from './solvable';
import { Probabilistic, deterministic, mapSecond } from './probabilistic';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { AlgCounts } from './alg-counts';
import { Decider } from './decider';
import { BufferState, emptyBufferState, newBufferState } from './buffer-state';
import { ParitySolver, createParitySolver } from './parity-solver';
import { TwistSolver, createTwistSolver } from './twist-solver';
import { ProbabilisticAlgTrace, withPrefix } from './solver-utils';

function pOrElseTryCall<X>(probOptX: Probabilistic<[Solvable, Optional<X>]>, probXGen: (solvable: Solvable) => ProbabilisticAnswer<[Solvable, Optional<X>]>): Probabilistic<[Solvable, Optional<X>]> {
  return probOptX.flatMap((solvable, optX) => {
    return orElseTryCall(mapOptional(optX, deterministic), probXGen(solvable));
  });
}

function pOrElseDeterministic<X>(probOptX: Probabilistic<[Solvable, Optional<X>]>, x: X): Probabilistic<X> {
  return probOptX.mapAnswer(optX => orElse(optX, x));
}

function pFilter(solvable: Solvable, x: X, probCond: (solvable: Solvable, x: X) => Probabilistic<[Solvable, boolean]>): Probabilistic<[Solvable, Optional<X>]> {
  return propCond(solvable, x).mapAnswer(answer => answer ? some(x) : none);
}

function pNot(probCond: Probabilistic<[Solvable, boolean]>): boolean {
  return probCond.mapAnswer(cond => !cond);
}

function decideNextBufferAmong(
  solvable: Solvable,
  probBufferCond: (solvable: Solvable, buffer: Piece) => ProbabilististicAnswer<boolean>,
  buffers: Piece[]): Probabilistic<[Solvable, Optional<Piece>]> {
  if (buffers.length === 0) {
    return deterministic(solvable, none);
  }
  const probMaybeBuffer = pFilter(solvable, buffers[0], probBufferCond);
  return pOrElseCall(probMaybeBuffer, solvable => this.decideNextBufferAmong(probBufferCond, buffers.slice(1)));
}

function decideNextBufferAmongPermuted(solvable: Solvable, buffers: Piece[]): Probabilistic<[Solvable, Optional<Piece>]> {
  return decideNextBufferAmong(solvable, (solvable, buffer) => solvable.decideIsPermuted());
}

function decideNextBufferAmongUnsolved(solvable: Solvable, buffers: Piece[]): Probabilistic<[Solvable, Optional<Piece>]> {
  return decideNextBufferAmong(solvable, (solvable, buffer) => pNot(solvable.decideIsPermuted()));
}

export class Solver {
  // The buffers sorted by priority.
  sortedBuffers: Piece[];

  constructor(private readonly decider: Decider, private readonly pieces: readonly Piece[], private readonly paritySolver: ParitySolver) {
    sortedBuffers = this.pieces.filter(piece => this.decider.isBuffer(piece)).sort((left, right) => this.decider.bufferPriority(right) - this.decider.bufferPriority(left));
  }

  get favoriteBuffer() {
    return this.sortedBuffers[0];
  }

  private decideNextBuffer(bufferState: BufferState, solvable: Solvable): Probabilistic<[Solvable, Piece]> {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return previousBuffer;
    }
    const previousBufferIndex = orElse(indexOf(this.sortedBuffers, previousBuffer), -1);
    const relevantBuffers = orderedBuffers.slice(previousBufferIndex + 1);
    const fallbackBuffer = previousBuffer && this.decider.stayWithSolvedBuffer(previousBuffer) ? previousBuffer : this.favoriteBuffer;
    if (decideNextBufferAmong(this.decider.avoidUnorientedIfWeCanFloat)) {
      return pOrElseDeterministic(pOrElseTryCall(decideNextBufferAmongPermuted(solvable, relevantBuffers), solvable => decideNextBufferAmongUnsolved(solvable, relevantBuffers)), fallbackBuffer);
    }
    return pOrElseDeterministic(decideNextBufferAmongUnsolved(solvable, relevantBuffers), fallbackBuffer);
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

  private algsWithSolvedDoubleSwapAndOrientedType(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap, orientedType: OrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applySolvedDoubleSwap(doubleSwap, orientedType);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable);
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithDoubleSwap(bufferState: BufferState, solvable: Solvable, doubleSwap: DoubleSwap): ProbabilisticAlgTrace {
    if (solvable.decideCycleLength(doubleSwap.thirdPiece).assertDeterministic()[1] === 2) {
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

  private algsWithEvenCycleWithOrientedType(bufferState: BufferState, solvable: Solvable, cycle: EvenCycle, orientedType: OrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyCompleteEvenCycle(cycle, orientedType);
    const remainingTraces = this.algs(bufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycle);
  }

  private unorientedAlgs(solvable: Solvable): ProbabilisticAlgTrace {
    assert(!solvable.hasPermuted, 'unorienteds cannot permute');
    return new ProbabilisticAlgTrace(this.twistSolver.algs(solvable.unorientedByType).map(algs => [solvable, algs]));
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
        const otherPiece = solvable.decideNextPiece(buffer).assertDeterministic()[1];
        return this.paritySolver.algsWithParity(solvable, new Parity(buffer, otherPiece));
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
      return deterministic([solvable, emptyAlgTrace()]);
    }
  }

  algCounts(solvable: Solvable): Probabilistic<AlgCounts> {
    return this.algs(emptyBufferState(), solvable).removeSolvables().map(algTrace => algTrace.withMaxCycleLength(buffer => this.decider.maxCycleLengthForBuffer(buffer)).countAlgs());
  }
}

export function createSolver(decider: Decider, pieceDescription: PieceDescription) {
  const twistSolver = createTwistSolver(decider, pieceDescription);
  return new Solver(decider, pieceDescription.pieces, createParitySolver(decider, twistSolver), twistSolver);
}
