import { deterministic, Probabilistic } from './probabilistic';
import { count, zip, sum, minBy, findIndex } from '../utils';
import { none, some, Optional, forceValue, ifPresentOrElse, hasValue } from '../optional';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { TwistWithCost } from './twist-with-cost';
import { Decider } from './decider';
import { PieceDescription } from './piece-description';
import { assert, assertEqual } from '../assert';
import { Solvable } from './solvable';
import { numOrientedTypes, OrientedType, solvedOrientedType } from './oriented-type';

function orientedTypesIndex(orientedTypes: readonly OrientedType[]) {
  const calculatedNumOrientedTypes = numOrientedTypes(orientedTypes);
  return sum(orientedTypes.map((orientedType, index) => orientedType.index * calculatedNumOrientedTypes ** index));
}

export interface TwistSolver {
  algs<T extends Solvable<T>>(solvable: T): Probabilistic<[T, AlgTrace]>;
  algsForOrientedTypes(orientedTypes: readonly OrientedType[]): Probabilistic<AlgTrace>;
}

class TwistSolverImpl implements TwistSolver {
  constructor(private readonly algsByIndex: Optional<AlgTrace>[]) {}

  algs<T extends Solvable<T>>(solvable: T): Probabilistic<[T, AlgTrace]> {
    return solvable.decideOrientedTypes().flatMap(([solvable, orientedTypes]) => {
      return this.algsForOrientedTypes(orientedTypes).map(algs => [solvable, algs]);
    });
  }

  algsForOrientedTypes(orientedTypes: readonly OrientedType[]): Probabilistic<AlgTrace> {
    const index = orientedTypesIndex(orientedTypes);
    const algTrace = forceValue(this.algsByIndex[index]);
    return deterministic(algTrace);
  }
}

interface AlgTraceWithCost {
  readonly index: number;
  readonly targetOrientedTypes: readonly OrientedType[];
  readonly algTrace: AlgTrace;
  readonly cost: number;
}

// Note that this is not efficient, but it doesn't have to be because we have only 8 corners and not that many twists.
class AlgTracesPriorityQueue {
  readonly elements: AlgTraceWithCost[] = [];

  get empty() {
    return this.elements.length === 0;
  }

  pushOrDecreaseCost(algTraceWithCost: AlgTraceWithCost) {
    const maybeReplacedIndex = findIndex(this.elements, e => e.index === algTraceWithCost.index);
    ifPresentOrElse(maybeReplacedIndex,
                    index => { this.elements[index] = algTraceWithCost; },
                    () => { this.elements.push(algTraceWithCost); });
  }

  extractMin(): AlgTraceWithCost {
    const unprocessedWithIndex: [AlgTraceWithCost, number][] = this.elements.map((e, i) => [e, i]);
    const min = forceValue(minBy(unprocessedWithIndex, e => e[0].cost));
    this.elements.splice(min[1], 1);
    return min[0];
  }
}

function combineOrientedTypess(left: readonly OrientedType[], right: readonly OrientedType[]): OrientedType[] {
  assertEqual(left.length, right.length);
  return zip(left, right).map(([left, right]) => left.plus(right));
}

function combine(algTraceWithCost: AlgTraceWithCost, twistWithCost: TwistWithCost): AlgTraceWithCost {
  const targetOrientedTypes = combineOrientedTypess(algTraceWithCost.targetOrientedTypes, twistWithCost.twist.orientedTypes);
  const index = orientedTypesIndex(targetOrientedTypes);
  return {
    targetOrientedTypes,
    index,
    algTrace: algTraceWithCost.algTrace.withSuffix(twistWithCost.twist),
    cost: algTraceWithCost.cost + twistWithCost.cost,
  };
}

export function createTwistSolver(decider: Decider, pieceDescription: PieceDescription): TwistSolver {
  return createTwistSolverInternal(decider.twistsWithCosts, pieceDescription);
}

// Exported for testing
export function createTwistSolverInternal(twistsWithCosts: readonly TwistWithCost[], pieceDescription: PieceDescription): TwistSolver {
  assert(pieceDescription.numOrientedTypes <= 3);
  const numItems = pieceDescription.numOrientedTypes ** pieceDescription.pieces.length;
  const algsByIndex: Optional<AlgTrace>[] = Array(numItems).fill(none);
  const costByIndex: number[] = Array(numItems).fill(Infinity);
  const targetOrientedTypes: readonly OrientedType[] = pieceDescription.pieces.map(() => solvedOrientedType);
  const index = orientedTypesIndex(targetOrientedTypes)
  const solvedAlgTraceWithCost: AlgTraceWithCost = {targetOrientedTypes, index, algTrace: emptyAlgTrace(), cost: 0};
  algsByIndex[index] = some(emptyAlgTrace());
  costByIndex[index] = 0;
  const unprocessed = new AlgTracesPriorityQueue();
  unprocessed.pushOrDecreaseCost(solvedAlgTraceWithCost);
  while (!unprocessed.empty) {
    const current = unprocessed.extractMin();
    for (let twistWithCost of twistsWithCosts) {
      const neighbor = combine(current, twistWithCost);
      const oldNeighborCost = costByIndex[neighbor.index];
      if (neighbor.cost < oldNeighborCost) {
        algsByIndex[neighbor.index] = some(neighbor.algTrace);
        costByIndex[neighbor.index] = neighbor.cost;
        unprocessed.pushOrDecreaseCost(neighbor);
      }
    }
  }
  const actualSolved = count(algsByIndex, hasValue);
  const expectedSolved = pieceDescription.numOrientedTypes ** (pieceDescription.pieces.length - 1);
  assert(actualSolved === expectedSolved, `The set of given twists is not sufficient to solve all twists (${actualSolved}/${expectedSolved})`);
  return new TwistSolverImpl(algsByIndex);
}
