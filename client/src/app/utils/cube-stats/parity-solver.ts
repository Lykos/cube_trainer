import { Parity, ThreeCycle, ParityTwist } from './alg';
import { Optional, flatMapOptional, mapOptional, orElseCall, none, some } from '../optional';
import { Piece } from './piece';
import { Solvable } from './solvable';
import { OrientedType } from './oriented-type';
import { ProbabilisticAlgTrace, withPrefix, decideFirstPieceWithCond, pMapSecond, pSecondNot } from './solver-utils';
import { TwistSolver } from './twist-solver';
import { Decider } from './decider';
import { Probabilistic } from './probabilistic';

function decideParityTwist<T extends Solvable<T>>(solvable: T, parity: Parity, sortedUnorienteds: readonly Piece[]): Probabilistic<[T, Optional<ParityTwist>]> {
  const pMaybeUnoriented = decideFirstPieceWithCond(solvable, (solvable, piece) => pSecondNot(solvable.decideIsOriented(piece)), sortedUnorienteds);
  return pMapSecond(pMaybeUnoriented,
                    maybeUnoriented => mapOptional(maybeUnoriented, unoriented => new ParityTwist(parity.firstPiece, parity.lastPiece, unoriented)));
}

// This solver takes over when only a parity and potentially some twists are left.
export class ParitySolver {
  constructor(private readonly decider: Decider, private readonly twistSolver: TwistSolver) {}

  private algsWithVanillaParity<T extends Solvable<T>>(solvable: T, parity: Parity): ProbabilisticAlgTrace<T> {
    return solvable.decideOnlyUnoriented().flatMap(([solvable, maybeOnlyUnoriented]) => {
      // If they want to do one other unoriented first, that can be done.
      const maybeTwistThenParity: Optional<ProbabilisticAlgTrace<T>> =
        flatMapOptional(maybeOnlyUnoriented, unoriented => {
          if (!this.decider.doUnorientedBeforeParity(parity, unoriented)) {
            return none;
          }
          const cycleBreak = new ThreeCycle(parity.firstPiece, parity.lastPiece, unoriented);
          const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
          const newParity = new Parity(parity.firstPiece, unoriented);
          const remainingTraces = this.algsWithParity(remainingSolvable, newParity);
          return some(withPrefix(remainingTraces, cycleBreak));
        });
      return orElseCall(maybeTwistThenParity, () => {
        return solvable.decideOrientedTypeForPieceCycle(parity.firstPiece).flatMap(([solvable, orientedType]) => {
          return this.algsWithVanillaParityWithOrientedType(solvable, parity, orientedType);
        })
      });
    });
  }

  private algsWithVanillaParityWithOrientedType<T extends Solvable<T>>(solvable: T, parity: Parity, orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyParity(parity, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parity);
  }

  private algsWithParityTwist<T extends Solvable<T>>(solvable: T, parityTwist: ParityTwist): ProbabilisticAlgTrace<T> {
    return solvable.decideOnlyUnorientedExcept(parityTwist.unoriented).flatMap(([solvable, maybeOnlyUnoriented]) => {
      // If they want to do one other unoriented first, that can be done.
      const maybeTwistThenParity: Optional<ProbabilisticAlgTrace<T>> =
        flatMapOptional(maybeOnlyUnoriented, unoriented => {
          if (!this.decider.doUnorientedBeforeParityTwist(parityTwist, unoriented)) {
            return none;
          }
          const cycleBreak = new ThreeCycle(parityTwist.firstPiece, parityTwist.lastPiece, unoriented);
          const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
          const newParity = new Parity(parityTwist.firstPiece, unoriented);
          const remainingTraces = this.algsWithParity(remainingSolvable, newParity);
          return some(withPrefix(remainingTraces, cycleBreak));
        });
      return orElseCall(maybeTwistThenParity, () => {
        return solvable.decideOrientedTypeForPieceCycle(parityTwist.firstPiece).flatMap(([solvable, orientedType]) => {
          return this.algsWithParityTwistWithOrientedType(solvable, parityTwist, orientedType);
        });
      });
    });
  }

  private algsWithParityTwistWithOrientedType<T extends Solvable<T>>(solvable: T, parityTwist: ParityTwist, orientedType: OrientedType): ProbabilisticAlgTrace<T> {
    const remainingSolvable = solvable.applyParityTwist(parityTwist, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parityTwist);
  };

  private sortedParityTwistUnorientedsForParity(parity: Parity) {
    return this.decider.sortedParityTwistUnorientedsForParity(parity).filter(p => p.pieceId !== parity.firstPiece.pieceId && p.pieceId !== parity.lastPiece.pieceId);
  }

  algsWithParity<T extends Solvable<T>>(solvable: T, parity: Parity): ProbabilisticAlgTrace<T> {
    const pMaybeParityTwist: Probabilistic<[T, Optional<ParityTwist>]> = decideParityTwist(solvable, parity, this.sortedParityTwistUnorientedsForParity(parity));
    return pMaybeParityTwist.flatMap(([solvable, maybeParityTwist]) => {
      const maybeParityTwistAlgs = mapOptional(maybeParityTwist, parityTwist => this.algsWithParityTwist(solvable, parityTwist));
      return orElseCall(maybeParityTwistAlgs, () => this.algsWithVanillaParity(solvable, parity));
    });
  }

  private unorientedAlgs<T extends Solvable<T>>(solvable: T): ProbabilisticAlgTrace<T> {
    return this.twistSolver.algs(solvable);
  }
}

export function createParitySolver(decider: Decider, twistSolver: TwistSolver) {
  return new ParitySolver(decider, twistSolver);
}
