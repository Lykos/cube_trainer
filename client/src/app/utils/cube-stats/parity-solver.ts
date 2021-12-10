import { Parity, ThreeCycle, ParityTwist } from './alg';
import { Solvable } from './solvable';
import { OrientedType } from './oriented-type';
import { ProbabilisticAlgTrace, withPrefix } from './solver-utils';
import { TwistSolver } from './twist-solver';
import { Decider } from './decider';

// This solver takes over when only a parity and potentially some twists are left.
export class ParitySolver {
  constructor(private readonly decider: Decider, private readonly twistSolver: TwistSolver) {}

  private algsWithVanillaParity<T>(solvable: Solvable<T>, parity: Parity): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (solvable.unoriented.length === 1) {
      const unoriented = solvable.unoriented[0];
      if (this.decider.doUnorientedBeforeParity(parity, unoriented)) {
        const cycleBreak = new ThreeCycle(parity.firstPiece, parity.lastPiece, unoriented);
        const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
        const newParity = new Parity(parity.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(remainingSolvable, newParity);
        return withPrefix(remainingTraces, cycleBreak);
      }
    }
    return solvable.decideOrientedTypeForPieces(parity.pieces).flatMap((solvable, orientedType) => {
      return this.algsWithVanillaParityWithOrientedType(solvable, parity, orientedType);
    });
  }

  private algsWithVanillaParityWithOrientedType<T>(solvable: Solvable<T>, parity: Parity, orientedType: OrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyParity(parity, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parity);
  }

  private algsWithParityTwist<T>(solvable: Solvable<T>, parityTwist: ParityTwist): ProbabilisticAlgTrace {
    // If they want to do one other unoriented first, that can be done.
    if (solvable.unoriented.length === 1) {
      const unoriented = solvable.unoriented[0];
      if (this.decider.doUnorientedBeforeParityTwist(parityTwist, unoriented)) {
        const cycleBreak = new ThreeCycle(parityTwist.firstPiece, parityTwist.lastPiece, unoriented);
        const remainingSolvable = solvable.applyCycleBreakFromSwap(cycleBreak);
        const newParity = new Parity(parityTwist.firstPiece, unoriented);
        const remainingTraces = this.algsWithParity(remainingSolvable, newParity);
        return withPrefix(remainingTraces, cycleBreak);
      }
    }
    return solvable.decideOrientedTypeForPieces(parityTwist.swappedPieces).flatMap((solvable, orientedType) => {
      return this.algsWithParityTwistWithOrientedType(solvable, parityTwist, orientedType);
    });
  }

  private algsWithParityTwistWithOrientedType<T>(solvable: Solvable<T>, parityTwist: ParityTwist, orientedType: OrientedType): ProbabilisticAlgTrace {
    const remainingSolvable = solvable.applyParityTwist(parityTwist, orientedType);
    const remainingTraces = this.unorientedAlgs(remainingSolvable);
    return withPrefix(remainingTraces, parityTwist);
  };

  algsWithParity<T>(solvable: Solvable<T>, parity: Parity): ProbabilisticAlgTrace {
    const buffer = parity.firstPiece;
    const otherPiece = parity.lastPiece;
    const parityTwistPieces = solvable.unoriented.filter(piece => this.decider.canParityTwist(new ParityTwist(buffer, otherPiece, piece)));
    const parityTwists = parityTwistPieces.map(piece => new ParityTwist(buffer, otherPiece, piece));
    const maybeParityTwist = minBy(parityTwists, parityTwist => this.decider.parityTwistPriority(parityTwist));
    return orElseCall(mapOptional(maybeParityTwist, parityTwist => this.algsWithParityTwist(solvable, parityTwist)),
                      () => this.algsWithVanillaParity(solvable, parity));
  }

  private unorientedAlgs<T>(solvable: Solvable<T>): ProbabilisticAlgTrace {
    assert(!solvable.hasPermuted, 'unorienteds cannot permute');
    return new ProbabilisticAlgTrace(this.twistSolver.algs(solvable.unorientedByType).map(algs => [solvable, algs]));
  }
}

export function createParitySolver(decider: Decider, twistSolver: TwistSolver) {
  return new ParitySolver(decider, createTwistSolver(pieceDescription, decider));
}
