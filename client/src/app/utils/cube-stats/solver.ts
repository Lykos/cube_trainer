import { orElse, forceValue, Optional, some, none, ifPresent } from '../optional';
import { findIndex } from '../utils';
import { assert } from '../assert';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { Parity, ThreeCycle, EvenCycle, DoubleSwap } from './alg';
import { Solvable } from './solvable';
import { OrientedType } from './oriented-type';
import { Probabilistic, deterministic } from './probabilistic';
import { AlgCounts } from './alg-counts';
import { Decider } from './decider';
import { BufferState, emptyBufferState, newBufferState } from './buffer-state';
import { ParitySolver, createParitySolver } from './parity-solver';
import { TwistSolver, createTwistSolver } from './twist-solver';
import { ProbabilisticAlgTrace, withPrefix, pMapSecond, pSecondNot, decideFirstPieceWithCond, pSecondOrElseTryCall } from './solver-utils';

function pSecondOrElseDeterministic<X, T extends Solvable<T>>(probOptX: Probabilistic<[T, Optional<X>]>, x: X): Probabilistic<[T, X]> {
  return pMapSecond(probOptX, optX => orElse(optX, x));
}

function pSecond<X, Y>(probabilistic: Probabilistic<[X, Y]>): Probabilistic<Y> {
  return probabilistic.map(([x, y]) => y);
}

function pSecondIfThenElse<X, Y>(pCond: Probabilistic<[X, boolean]>,
				 pThenF: (x: X) => Probabilistic<[X, Y]>,
				 pElseF: (x: X) => Probabilistic<[X, Y]>): Probabilistic<[X, Y]> {
  return pCond.flatMap(([x, cond]) => {
    return cond ? pThenF(x) : pElseF(x);
  });
}

function decideNextBufferAmongPermuted<T extends Solvable<T>>(solvable: T, buffers: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  return decideFirstPieceWithCond(solvable, (solvable, buffer) => solvable.decideIsPermuted(buffer), buffers);
}

function decideNextBufferAmongUnsolved<T extends Solvable<T>>(solvable: T, buffers: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  return decideFirstPieceWithCond(solvable, (solvable, buffer) => pSecondNot(solvable.decideIsSolved(buffer)), buffers);
}

function decideNextCycleBreak<T extends Solvable<T>>(solvable: T, pieces: readonly Piece[]): Probabilistic<[T, Piece]> {
  return pMapSecond(decideFirstPieceWithCond(solvable, (solvable, piece) => solvable.decideIsPermuted(piece), pieces), forceValue);
}

export class Solver {
  constructor(private readonly decider: Decider,
	      private readonly paritySolver: ParitySolver,
	      private readonly twistSolver: TwistSolver) {}

  private get sortedBuffers() {
    return this.decider.sortedBuffers;
  }

  private get favoriteBuffer() {
    return this.sortedBuffers[0];
  }

  private decideNextBuffer<T extends Solvable<T>>(bufferState: BufferState, solvable: T): Probabilistic<[T, Piece]> {
    const previousBuffer = bufferState.previousBuffer;
    if (previousBuffer && !this.decider.canChangeBuffer(bufferState)) {
      return deterministic([solvable, previousBuffer]);
    }
    const previousBufferIndex = orElse(findIndex(this.sortedBuffers, p => p.pieceId === previousBuffer?.pieceId), -1);
    const relevantBuffers = this.sortedBuffers.slice(previousBufferIndex + 1);
    const fallbackBuffer = previousBuffer && this.decider.stayWithSolvedBuffer(previousBuffer) ? previousBuffer : this.favoriteBuffer;
    if (this.decider.avoidUnorientedIfWeCanFloat) {
      return pSecondOrElseDeterministic(
	pSecondOrElseTryCall(
	  decideNextBufferAmongPermuted(solvable, relevantBuffers),
	  solvable => decideNextBufferAmongUnsolved(solvable, relevantBuffers)),
	fallbackBuffer);
    }
    return pSecondOrElseDeterministic(
      decideNextBufferAmongUnsolved(solvable, relevantBuffers),
      fallbackBuffer);
  }

  private algsWithPartialDoubleSwap<T extends Solvable<T>>(bufferState: BufferState, solvable: T, decreasingNumber: number, doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyPartialDoubleSwap(doubleSwap);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithCompleteDoubleSwap<T extends Solvable<T>>(bufferState: BufferState,
                                                            solvable: T,
                                                            decreasingNumber: number,
                                                            doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    return solvable.decideOrientedTypeForPieceCycle(doubleSwap.thirdPiece).flatMap(([solvable, orientedType]) => {
      return this.algsWithCompleteDoubleSwapAndOrientedType(bufferState, solvable, decreasingNumber, doubleSwap, orientedType);
    });
  }

  private algsWithCompleteDoubleSwapAndOrientedType<T extends Solvable<T>>(bufferState: BufferState,
                                                                           solvable: T,
                                                                           decreasingNumber: number,
                                                                           doubleSwap: DoubleSwap,
                                                                           orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCompleteDoubleSwap(doubleSwap, orientedType);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithDoubleSwap<T extends Solvable<T>>(bufferState: BufferState,
                                                    solvable: T,
                                                    decreasingNumber: number,
                                                    doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    if (solvable.decideCycleLength(doubleSwap.thirdPiece).assertDeterministic()[1] === 2) {
      return this.algsWithCompleteDoubleSwap(bufferState, solvable, decreasingNumber, doubleSwap);
    } else {
      return this.algsWithPartialDoubleSwap(bufferState, solvable, decreasingNumber, doubleSwap);
    }
  }

  private algsWithCycleBreakFromSwap<T extends Solvable<T>>(bufferState: BufferState,
                                                            solvable: T,
                                                            decreasingNumber: number,
                                                            cycleBreak: ThreeCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithCycleBreakFromUnpermuted<T extends Solvable<T>>(bufferState: BufferState,
                                                                  solvable: T,
                                                                  decreasingNumber: number,
                                                                  cycleBreak: ThreeCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCycleBreakFromUnpermuted(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithEvenCycle<T extends Solvable<T>>(bufferState: BufferState,
                                                   solvable: T,
                                                   decreasingNumber: number,
                                                   cycle: EvenCycle): ProbabilisticAlgTrace<T> {
    return solvable.decideOrientedTypeForPieceCycle(cycle.firstPiece).flatMap(([solvable, orientedType]) => {
      return this.algsWithEvenCycleWithOrientedType(bufferState, solvable, decreasingNumber, cycle, orientedType);
    });
  }

  private algsWithEvenCycleWithOrientedType<T extends Solvable<T>>(bufferState: BufferState,
                                                                   solvable: T,
                                                                   decreasingNumber: number,
                                                                   cycle: EvenCycle,
                                                                   orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCompleteEvenCycle(cycle, orientedType);
    const remainingTraces = this.algs(bufferState, remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, cycle);
  }

  private unorientedAlgs<T extends Solvable<T>>(solvable: T): ProbabilisticAlgTrace<T> {
    return this.twistSolver.algs(solvable);
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPiece<T extends Solvable<T>>(bufferState: BufferState,
                                                                               solvable: T,
                                                                               decreasingNumber: number, 
                                                                               buffer: Piece,
                                                                               otherPiece: Piece,
                                                                               cycleBreak: Piece,
                                                                               nextPiece: Piece): ProbabilisticAlgTrace<T> {
    return solvable.decideOrientedTypeForPieceCycle(buffer).flatMap(([solvable, orientedType]) => {
      return this.cycleBreakWithBufferAndOtherPieceAndNextPieceAndOrientedType(bufferState, solvable, decreasingNumber, buffer, otherPiece, cycleBreak, nextPiece, orientedType);
    });
  }

  private canDoubleSwap(doubleSwap: DoubleSwap, orientedType: OrientedType) {
    return this.decider.canDoubleSwap(doubleSwap, orientedType) && this.sortedBuffers.some(b => b.pieceId === doubleSwap.thirdPiece.pieceId);
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPieceAndOrientedType<T extends Solvable<T>>(bufferState: BufferState,
                                                                                              solvable: T,
                                                                                              decreasingNumber: number, 
                                                                                              buffer: Piece,
                                                                                              otherPiece: Piece,
                                                                                              cycleBreak: Piece,
                                                                                              nextPiece: Piece,
                                                                                              orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    if (this.decider.canChangeBuffer(bufferState) && this.canDoubleSwap(doubleSwap, orientedType)) {
      return this.algsWithDoubleSwap(bufferState, solvable, decreasingNumber, doubleSwap);
    }
    return this.algsWithCycleBreakFromSwap(bufferState, solvable, decreasingNumber, new ThreeCycle(buffer, otherPiece, cycleBreak));
  }

  private sortedNextCycleBreaksOnSecondPiece(buffer: Piece, firstPiece: Piece): readonly Piece[] {
    return this.decider.piecePermutationDescription.pieces.filter(p => p.pieceId !== buffer.pieceId && p.pieceId !== firstPiece.pieceId);
  }

  private sortedNextCycleBreaksOnFirstPiece(buffer: Piece): readonly Piece[] {
    return this.decider.piecePermutationDescription.pieces.filter(p => p.pieceId !== buffer.pieceId);
  }

  private cycleBreakWithBufferAndOtherPiece<T extends Solvable<T>>(bufferState: BufferState,
                                                                   solvable: T,
                                                                   decreasingNumber: number,
                                                                   buffer: Piece,
                                                                   otherPiece: Piece): ProbabilisticAlgTrace<T> {
    return decideNextCycleBreak(solvable, this.sortedNextCycleBreaksOnSecondPiece(buffer, otherPiece)).flatMap(([solvable, cycleBreakPiece]) => {
      return solvable.decideNextPiece(cycleBreakPiece).flatMap(([solvable, nextPiece]) => {
	return this.cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState, solvable, decreasingNumber, buffer, otherPiece, cycleBreakPiece, nextPiece);
      });
    });
  }

  private algsWithPartialCycle<T extends Solvable<T>>(bufferState: BufferState, solvable: T, decreasingNumber: number, cycle: EvenCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyPartialEvenCycle(cycle);
    const remainingTraces = this.algs(bufferState, remainingSolvable, some(decreasingNumber));
    return withPrefix(remainingTraces, cycle);
  }

  private algsWithParityAndBuffer<T extends Solvable<T>>(solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    const otherPiece = solvable.decideNextPiece(buffer).assertDeterministic()[1];
    return this.paritySolver.algsWithParity(solvable, new Parity(buffer, otherPiece));
  }

  private algsWithCycleBreakAndPermutedBuffer<T extends Solvable<T>>(bufferState: BufferState, solvable: T, decreasingNumber: number, buffer: Piece): ProbabilisticAlgTrace<T> {
    return solvable.decideNextPiece(buffer).flatMap(([solvable, otherPiece]) => {
      return this.cycleBreakWithBufferAndOtherPiece(bufferState, solvable, decreasingNumber, buffer, otherPiece);
    });
  }

  private algsWithPermutedBufferAndCycleLength<T extends Solvable<T>>(bufferState: BufferState, solvable: T, decreasingNumber: number, buffer: Piece, cycleLength: number): ProbabilisticAlgTrace<T> {
    if (cycleLength === 2) {
      return pSecondIfThenElse(
	solvable.decideIsParityTime(),
	solvable => this.algsWithParityAndBuffer(solvable, buffer),
	solvable => this.algsWithCycleBreakAndPermutedBuffer(bufferState, solvable, decreasingNumber, buffer));
    } else if (cycleLength % 2 === 1) {
      return this.algsWithEvenCycle(bufferState, solvable, decreasingNumber, new EvenCycle(buffer, cycleLength - 1));
    } else {
      return this.algsWithPartialCycle(bufferState, solvable, decreasingNumber, new EvenCycle(buffer, cycleLength - 2));
    }
  }

  private algsWithPermutedBuffer<T extends Solvable<T>>(bufferState: BufferState,
                                                        solvable: T,
                                                        decreasingNumber: number,
                                                        buffer: Piece): ProbabilisticAlgTrace<T> {
    return solvable.decideCycleLength(buffer).flatMap(([solvable, cycleLength]) => {
      return this.algsWithPermutedBufferAndCycleLength(bufferState, solvable, decreasingNumber, buffer, cycleLength);
    });
  }

  private algsWithUnpermutedBufferAndPermutedRest<T extends Solvable<T>>(bufferState: BufferState,
                                                                         solvable: T,
                                                                         decreasingNumber: number,
                                                                         buffer: Piece): ProbabilisticAlgTrace<T> {
    return decideNextCycleBreak(solvable, this.sortedNextCycleBreaksOnFirstPiece(buffer)).flatMap(([solvable, cycleBreakPiece]) => {
      return solvable.decideNextPiece(cycleBreakPiece).flatMap(([solvable, nextPiece]) => {
	return this.algsWithCycleBreakFromUnpermuted(bufferState, solvable, decreasingNumber, new ThreeCycle(buffer, cycleBreakPiece, nextPiece));
      });
    });
  }

  private algsWithUnpermutedBuffer<T extends Solvable<T>>(bufferState: BufferState,
							  solvable: T,
                                                          decreasingNumber: number,
							  buffer: Piece): ProbabilisticAlgTrace<T> {
    return pSecondIfThenElse(
      solvable.decideHasPermuted(),
      solvable => this.algsWithUnpermutedBufferAndPermutedRest(bufferState, solvable, decreasingNumber, buffer),
      solvable => this.unorientedAlgs(solvable));
  }

  private algs<T extends Solvable<T>>(bufferState: BufferState, solvable: T, decreasingNumber: Optional<number>): ProbabilisticAlgTrace<T> {
    // In order to avoid infinite loops, we check that the number of swaps decreases.
    // Because breaking into a new cycle from a new buffer doesn't decrease the number of swaps,
    // we add 1 as a single-use joker if we can.
    let nextDecreasingNumber = (solvable.numPermuted() + solvable.numCycles()) * 2;
    if (nextDecreasingNumber + 1 < orElse(decreasingNumber, Infinity)) {
      ++nextDecreasingNumber;
    }
    ifPresent(decreasingNumber, decreasingNumber => {
      assert(nextDecreasingNumber < decreasingNumber, 'decreasing number not decreasing');
    });
    return this.decideNextBuffer(bufferState, solvable).flatMap(([solvable, buffer]) => {
      if (buffer.pieceId !== bufferState.previousBuffer?.pieceId) {
	bufferState = emptyBufferState();
      }
      return this.algsWithBuffer(bufferState, solvable, nextDecreasingNumber, buffer);
    });
  }

  private algsWithBuffer<T extends Solvable<T>>(bufferState: BufferState,
                                                solvable: T,
                                                decreasingNumber: number,
                                                buffer: Piece): ProbabilisticAlgTrace<T> {
    return pSecondIfThenElse(
      solvable.decideIsPermuted(buffer),
      solvable => this.algsWithPermutedBuffer(bufferState, solvable, decreasingNumber, buffer),
      solvable => this.algsWithUnpermutedBuffer(bufferState, solvable, decreasingNumber, buffer));
  }

  algCounts<T extends Solvable<T>>(solvable: T): Probabilistic<AlgCounts> {
    const algTraces = pSecond(this.algs(emptyBufferState(), solvable, none))
    const adjustedAlgTraces = algTraces.map(algTrace => algTrace.withMaxCycleLength((buffer: Piece) => this.decider.maxCycleLengthForBuffer(buffer)));
    const algCounts = adjustedAlgTraces.map(algTrace => algTrace.countAlgs());
    return algCounts;
  }
}

export function createSolver(decider: Decider, pieceDescription: PieceDescription) {
  const twistSolver = createTwistSolver(decider, pieceDescription);
  return new Solver(decider, createParitySolver(decider, twistSolver), twistSolver);
}
