import { deterministic, Probabilistic } from './probabilistic';
import { Piece } from './piece';
import { count, sum, minBy, findIndex, contains } from '../utils';
import { none, some, Optional, forceValue, mapOptional, ifPresentOrElse, orElse, hasValue } from '../optional';
import { AlgTrace, emptyAlgTrace } from './alg-trace';
import { TwistWithCost } from './twist-with-cost';
import { PieceDescription } from './piece-description';
import { assert, assertEqual } from '../assert';

function unorientedByTypeIndex(unorientedByType: Piece[][]) {
  const orientedTypes = unorientedByType.length + 1;
  return sum(unorientedByType.map((unorientedForType, unorientedType) => {
    const orientedType = unorientedType + 1;
    return sum(unorientedForType.map(piece => orientedType * orientedTypes ** piece.pieceId));
  }));
}

export interface TwistSolver {
  algs(unorientedByType: Piece[][]): Probabilistic<AlgTrace>;
}

class TwistSolverImpl implements TwistSolver {
  constructor(private readonly algsByIndex: Optional<AlgTrace>[]) {}

  algs(unorientedByType: Piece[][]): Probabilistic<AlgTrace> {
    const index = unorientedByTypeIndex(unorientedByType);
    if (!hasValue(this.algsByIndex[index])) {
      console.log(this);
      console.log(unorientedByType);
    }
    const algTrace = forceValue(this.algsByIndex[index]);
    return deterministic(algTrace);
  }
}

interface AlgTraceWithCost {
  readonly index: number;
  readonly targetUnorientedByType: Piece[][];
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

function orientedTypeForPiece(unorientedByType: Piece[][], piece: Piece) {
  const maybeUnorientedType = findIndex(unorientedByType, unorientedForType => contains(unorientedForType, piece));
  const maybeOrientedType = mapOptional(maybeUnorientedType, unorientedType => unorientedType + 1)
  return orElse(maybeOrientedType, 0);
}

function combineUnorientedByTypes(left: Piece[][], right: Piece[][]): Piece[][] {
  assertEqual(left.length, right.length);
  const unorientedTypes = left.length;
  assert(unorientedTypes <= 2);
  const orientedTypes = unorientedTypes + 1;
  const pieces: Piece[] = left.flat(1).concat(right.flat(1));
  const result: Piece[][] = left.map(() => []);
  for (let piece of pieces) {
    const leftOrientedType = orientedTypeForPiece(left, piece);
    const rightOrientedType = orientedTypeForPiece(right, piece);
    const orientedType = (leftOrientedType + rightOrientedType) % orientedTypes;
    if (orientedType !== 0) {
      const unorientedType = orientedType - 1;
      result[unorientedType].push(piece);
    }
  }
  return result;
}

function combine(algTraceWithCost: AlgTraceWithCost, twistWithCost: TwistWithCost): AlgTraceWithCost {
  const targetUnorientedByType = combineUnorientedByTypes(algTraceWithCost.targetUnorientedByType, twistWithCost.twist.unorientedByType);
  const index = unorientedByTypeIndex(targetUnorientedByType);
  return {
    targetUnorientedByType,
    index,
    algTrace: algTraceWithCost.algTrace.withSuffix(twistWithCost.twist),
    cost: algTraceWithCost.cost + twistWithCost.cost,
  };
}

export function createTwistSolver(decider: Decider, pieceDescription: PieceDescription): TwistSolver {
  assert(pieceDescription.unorientedTypes <= 2);
  const twistsWithCosts: TwistWithCost[] = decider.twistsWithCosts;
  const numItems = pieceDescription.orientedTypes ** pieceDescription.pieces.length;
  const algsByIndex: Optional<AlgTrace>[] = Array(numItems).fill(none);
  const costByIndex: number[] = Array(numItems).fill(Infinity);
  const targetUnorientedByType: Piece[][] = Array(pieceDescription.unorientedTypes).fill([]);
  const index = unorientedByTypeIndex(targetUnorientedByType);
  const solvedAlgTraceWithCost: AlgTraceWithCost = {targetUnorientedByType, index, algTrace: emptyAlgTrace(), cost: 0};
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
  const expectedSolved = pieceDescription.orientedTypes ** (pieceDescription.pieces.length - 1);
  assert(actualSolved === expectedSolved, `The set of given twists is not sufficient to solve all twists (${actualSolved}/${expectedSolved})`);
  return new TwistSolverImpl(algsByIndex);
}
