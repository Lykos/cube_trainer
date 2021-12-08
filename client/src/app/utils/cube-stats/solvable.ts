import { Probabilistic, ProbabilisticPossibility, deterministic } from './probabilistic';
import { Parity, ThreeCycle, EvenCycle, ParityTwist, DoubleSwap } from './alg';
import { Piece } from './piece';

type SolvableWithAnswer<X> = [Solvable, X];

type PossibleSolvableWithAnswer<X> = ProbabilisticPossibility<SolvableWithAnswer<X>>;

// Represents an orientation type like CW or CCW.
// Except for the special value -1, it may or may not be known which of these maps to CW and which to CCW.
export class PartiallyFixedOrientedType {
  constructor(
    readonly isSolved: boolean,
    readonly index: number) {}
}

const solvedOrientedType = new PartiallyFixedOrientedType(true, -1);

function unfixedOrientedType(index: number) {
  return new PartiallyFixedOrientedType(false, index);
}

export class ProbabilisticAnswer<X> {
  constructor(private readonly probabilisticSolvableAndAnswer: Probabilistic<SolvableWithAnswer<X>>) {}

  removeSolvables(): Probabilistic<X> {
    return this.probabilisticSolvableAndAnswer.map(solvableWithAnswer => {
      const [_, answer] = solvableWithAnswer;
      return answer;
    });
  }

  mapAnswer<Y>(f: (x: X) => Y): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.probabilisticSolvableAndAnswer.map(solvableAndAnswer => {
      const [solvable, x] = solvableAndAnswer;
      return [solvable, f(x)];
    }));
  }

  flatMap<Y>(f: (solvable: Solvable, x: X) => ProbabilisticAnswer<Y>): ProbabilisticAnswer<Y> {
    return new ProbabilisticAnswer<Y>(this.probabilisticSolvableAndAnswer.flatMap(solvableAndAnswer => {
      const [solvable, x] = solvableAndAnswer;
      return f(solvable, x).probabilisticSolvableAndAnswer;
    }));
  }

  assertDeterministicAnswer(): X {
    return this.probabilisticSolvableAndAnswer.assertDeterministic()[1];
  }
}

export function deterministicAnswer<X>(solvable: Solvable, x: X) {
  return new ProbabilisticAnswer<X>(deterministic([solvable, x]));
}

export function probabilisticAnswer<X>(solvablesWithAnswers: PossibleSolvableWithAnswer<X>[]): ProbabilisticAnswer<X> {
  return new ProbabilisticAnswer<X>(new Probabilistic<SolvableWithAnswer<X>>(solvablesWithAnswers));
}

interface Solvable {
  isSolved(piece: Piece): boolean;
  isPermuted(piece: Piece): boolean;
  readonly hasPermuted: boolean;
  readonly parityTime: boolean;
  readonly unorientedByType: (readonly Piece[])[];
  readonly unoriented: readonly Piece[];

  applyCycleBreakFromSwap(cycleBreak: CycleBreak);
  applyCycleBreakFromUnpermuted(cycleBreak: CycleBreak);
  applyParity(parity: Parity);
  applyParityTwist(parity: ParityTwist);
  applyPartialDoubleSwap(doubleSwap: DoubleSwap);
  applyCompleteDoubleSwap(doubleSwap: DoubleSwap);
  applyCompleteEvenCycle(doubleSwap: EvenCycle);
  applyPartialEvenCycle(doubleSwap: EvenCycle);

  decideOrientedTypeForPieces(piece: readonly Piece[]): OrientedType;
  decideCycleLength(piece: Piece): number;
  decideNextPiece(piece: Piece): Piece;
}
