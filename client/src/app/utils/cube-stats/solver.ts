import { orElseCall, mapOptional, orElse, forceValue, Optional, none, some } from '../optional';
import { indexOf } from '../utils';
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
import { ProbabilisticAlgTrace, withPrefix, pMapSecond } from './solver-utils';

function pSecondOrElseTryCall<X, T extends Solvable<T>>(pOptX: Probabilistic<[T, Optional<X>]>, pXGen: (solvable: T) => Probabilistic<[T, Optional<X>]>): Probabilistic<[T, Optional<X>]> {
  return pOptX.flatMap(([solvable, optX]) => {
    const optPX: Optional<Probabilistic<[T, Optional<X>]>> = mapOptional(optX, x => deterministic([solvable, some(x)]));
    return orElseCall(optPX, () => pXGen(solvable));
  });
}

function pSecondOrElseDeterministic<X, T extends Solvable<T>>(probOptX: Probabilistic<[T, Optional<X>]>, x: X): Probabilistic<[T, X]> {
  return pMapSecond(probOptX, optX => orElse(optX, x));
}

function pFilter<X, T extends Solvable<T>>(solvable: T, x: X, pCond: (solvable: T, x: X) => Probabilistic<[T, boolean]>): Probabilistic<[T, Optional<X>]> {
  return pMapSecond(pCond(solvable, x), answer => answer ? some(x) : none);
}

function pSecondNot<T extends Solvable<T>>(probCond: Probabilistic<[T, boolean]>): Probabilistic<[T, boolean]> {
  return pMapSecond(probCond, cond => !cond);
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

function decideFirstPieceWithCond<T extends Solvable<T>>(
  solvable: T,
  pCond: (solvable: T, buffer: Piece) => Probabilistic<[T, boolean]>,
  pieces: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  if (pieces.length === 0) {
    return deterministic([solvable, none]);
  }
  const pMaybeGoodPiece = pFilter(solvable, pieces[0], pCond);
  return pSecondOrElseTryCall(pMaybeGoodPiece, solvable => decideFirstPieceWithCond(solvable, pCond, pieces.slice(1)));
}

function decideNextBufferAmongPermuted<T extends Solvable<T>>(solvable: T, buffers: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  return decideFirstPieceWithCond(solvable, (solvable, buffer) => solvable.decideIsPermuted(buffer), buffers);
}

function decideNextBufferAmongUnsolved<T extends Solvable<T>>(solvable: T, buffers: readonly Piece[]): Probabilistic<[T, Optional<Piece>]> {
  return decideFirstPieceWithCond(solvable, (solvable, buffer) => pSecondNot(solvable.decideIsPermuted(buffer)), buffers);
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
    const previousBufferIndex = orElse(indexOf(this.sortedBuffers, previousBuffer), -1);
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

  private algsWithPartialDoubleSwap<T extends Solvable<T>>(bufferState: BufferState, solvable: T, doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyPartialDoubleSwap(doubleSwap);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable);
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithCompleteDoubleSwap<T extends Solvable<T>>(bufferState: BufferState, solvable: T, doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    return solvable.decideOrientedTypeForPiece(doubleSwap.thirdPiece).flatMap(([solvable, orientedType]) => {
      return this.algsWithCompleteDoubleSwapAndOrientedType(bufferState, solvable, doubleSwap, orientedType);
    });
  }

  private algsWithCompleteDoubleSwapAndOrientedType<T extends Solvable<T>>(bufferState: BufferState, solvable: T, doubleSwap: DoubleSwap, orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCompleteDoubleSwap(doubleSwap, orientedType);
    const remainingTraces = this.algs(newBufferState(doubleSwap.thirdPiece), remainingSolvable);
    return withPrefix(remainingTraces, doubleSwap);
  }

  private algsWithDoubleSwap<T extends Solvable<T>>(bufferState: BufferState, solvable: T, doubleSwap: DoubleSwap): ProbabilisticAlgTrace<T> {
    if (solvable.decideCycleLength(doubleSwap.thirdPiece).assertDeterministic()[1] === 2) {
      return this.algsWithCompleteDoubleSwap(bufferState, solvable, doubleSwap);
    } else {
      return this.algsWithPartialDoubleSwap(bufferState, solvable, doubleSwap);
    }
  }

  private algsWithCycleBreakFromSwap<T extends Solvable<T>>(bufferState: BufferState, solvable: T, cycleBreak: ThreeCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithCycleBreakFromUnpermuted<T extends Solvable<T>>(bufferState: BufferState, solvable: T, cycleBreak: ThreeCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCycleBreakFromUnpermuted(cycleBreak);
    const nextBufferState = bufferState.withCycleBreak();
    const remainingTraces = this.algs(nextBufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycleBreak);
  }

  private algsWithEvenCycle<T extends Solvable<T>>(bufferState: BufferState, solvable: T, cycle: EvenCycle): ProbabilisticAlgTrace<T> {
    return solvable.decideOrientedTypeForPiece(cycle.firstPiece).flatMap(([solvable, orientedType]) => {
      return this.algsWithEvenCycleWithOrientedType(bufferState, solvable, cycle, orientedType);
    });
  }

  private algsWithEvenCycleWithOrientedType<T extends Solvable<T>>(bufferState: BufferState, solvable: T, cycle: EvenCycle, orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyCompleteEvenCycle(cycle, orientedType);
    const remainingTraces = this.algs(bufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycle);
  }

  private unorientedAlgs<T extends Solvable<T>>(solvable: T): ProbabilisticAlgTrace<T> {
    return this.twistSolver.algs(solvable);
  }

  private cycleBreakWithBufferAndOtherPieceAndNextPiece<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece, otherPiece: Piece, cycleBreak: Piece, nextPiece: Piece): ProbabilisticAlgTrace<T> {
    const doubleSwap = new DoubleSwap(buffer, otherPiece, cycleBreak, nextPiece);
    if (this.decider.canChangeBuffer(bufferState) && this.decider.canDoubleSwap(doubleSwap)) {
      return this.algsWithDoubleSwap(bufferState, solvable, doubleSwap);
    }
    return this.algsWithCycleBreakFromSwap(bufferState, solvable, new ThreeCycle(buffer, otherPiece, cycleBreak));
  }

  private sortedNextCycleBreaksOnSecondPiece(buffer: Piece, firstPiece: Piece): readonly Piece[] {
    return this.decider.piecePermutationDescription.pieces.filter(p => p !== buffer && p !== firstPiece);
  }

  private sortedNextCycleBreaksOnFirstPiece(buffer: Piece): readonly Piece[] {
    return this.decider.piecePermutationDescription.pieces.filter(p => p !== buffer);
  }

  private cycleBreakWithBufferAndOtherPiece<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece, otherPiece: Piece): ProbabilisticAlgTrace<T> {
    return decideNextCycleBreak(solvable, this.sortedNextCycleBreaksOnSecondPiece(buffer, otherPiece)).flatMap(([solvable, cycleBreakPiece]) => {
      return solvable.decideNextPiece(cycleBreakPiece).flatMap(([solvable, nextPiece]) => {
	return this.cycleBreakWithBufferAndOtherPieceAndNextPiece(bufferState, solvable, buffer, otherPiece, cycleBreakPiece, nextPiece);
      });
    });
  }

  private algsWithPartialCycle<T extends Solvable<T>>(bufferState: BufferState, solvable: T, cycle: EvenCycle): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyPartialEvenCycle(cycle);
    const remainingTraces = this.algs(bufferState, remainingSolvable);
    return withPrefix(remainingTraces, cycle);
  }

  private algsWithParityAndBuffer<T extends Solvable<T>>(solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    const otherPiece = solvable.decideNextPiece(buffer).assertDeterministic()[1];
    return this.paritySolver.algsWithParity(solvable, new Parity(buffer, otherPiece));
  }

  private algsWithCycleBreakAndPermutedBuffer<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    return solvable.decideNextPiece(buffer).flatMap(([solvable, otherPiece]) => {
      return this.cycleBreakWithBufferAndOtherPiece(bufferState, solvable, buffer, otherPiece);
    });
  }

  private algsWithPermutedBufferAndCycleLength<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece, cycleLength: number): ProbabilisticAlgTrace<T> {
    if (cycleLength === 2) {
      return pSecondIfThenElse(
	solvable.decideIsParityTime(),
	solvable => this.algsWithParityAndBuffer(solvable, buffer),
	solvable => this.algsWithCycleBreakAndPermutedBuffer(bufferState, solvable, buffer));
    } else if (cycleLength % 2 === 1) {
      return this.algsWithEvenCycle(bufferState, solvable, new EvenCycle(buffer, cycleLength - 1));
    } else {
      return this.algsWithPartialCycle(bufferState, solvable, new EvenCycle(buffer, cycleLength - 2));
    }
  }

  private algsWithPermutedBuffer<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    return solvable.decideCycleLength(buffer).flatMap(([solvable, cycleLength]) => {
      return this.algsWithPermutedBufferAndCycleLength(bufferState, solvable, buffer, cycleLength);
    });
  }

  private algsWithUnpermutedBufferAndPermutedRest<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    return decideNextCycleBreak(solvable, this.sortedNextCycleBreaksOnFirstPiece(buffer)).flatMap(([solvable, cycleBreakPiece]) => {
      return solvable.decideNextPiece(cycleBreakPiece).flatMap(([solvable, nextPiece]) => {
	return this.algsWithCycleBreakFromUnpermuted(bufferState, solvable, new ThreeCycle(buffer, cycleBreakPiece, nextPiece));
      });
    });
  }

  private algsWithUnpermutedBuffer<T extends Solvable<T>>(bufferState: BufferState,
							  solvable: T,
							  buffer: Piece): ProbabilisticAlgTrace<T> {
    return pSecondIfThenElse(
      solvable.decideHasPermuted(),
      solvable => this.algsWithUnpermutedBufferAndPermutedRest(bufferState, solvable, buffer),
      solvable => this.unorientedAlgs(solvable));
  }

  private algs<T extends Solvable<T>>(bufferState: BufferState, solvable: T): ProbabilisticAlgTrace<T> {
    return this.decideNextBuffer(bufferState, solvable).flatMap(([solvable, buffer]) => {
      if (buffer !== bufferState.previousBuffer) {
	bufferState = emptyBufferState();
      }
      return this.algsWithBuffer(bufferState, solvable, buffer);
    });
  }

  private algsWithBuffer<T extends Solvable<T>>(bufferState: BufferState, solvable: T, buffer: Piece): ProbabilisticAlgTrace<T> {
    return pSecondIfThenElse(
      solvable.decideIsPermuted(buffer),
      solvable => this.algsWithPermutedBuffer(bufferState, solvable, buffer),
      solvable => this.algsWithUnpermutedBuffer(bufferState, solvable, buffer));
  }

  algCounts<T extends Solvable<T>>(solvable: T): Probabilistic<AlgCounts> {
    return pSecond(this.algs(emptyBufferState(), solvable)).map(algTrace => algTrace.withMaxCycleLength((buffer: Piece) => this.decider.maxCycleLengthForBuffer(buffer)).countAlgs());
  }
}

export function createSolver(decider: Decider, pieceDescription: PieceDescription) {
  const twistSolver = createTwistSolver(decider, pieceDescription);
  return new Solver(decider, createParitySolver(decider, twistSolver), twistSolver);
}
