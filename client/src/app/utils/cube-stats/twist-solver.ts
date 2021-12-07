import { deterministic, Probabilistic } from './probabilistic';
import { Piece } from './piece';
import { sum, minBy, findIndex, contains } from '../utils';
import { none, some, Optional, forceValue, mapOptional, orElse } from '../optional';
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
    const algTrace = forceValue(this.algsByIndex[index]);
    return deterministic(algTrace);
  }
}

interface AlgTraceWithCost {
  targetUnorientedByType: Piece[][];
  algTrace: AlgTrace;
  cost: number;
}

// Note that this is not efficient, but it doesn't have to be because we have only 8 corners and not that many twists.
function extractMin(unprocessed: AlgTraceWithCost[]): AlgTraceWithCost {
  const unprocessedWithIndex: [AlgTraceWithCost, number][] = unprocessed.map((e, i) => [e, i]);
  const min = forceValue(minBy(unprocessedWithIndex, e => e[0].cost));
  unprocessed.splice(min[1], 1);
  return min[0];
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
    const rightOrientedType = orientedTypeForPiece(left, piece);
    const orientedType = (leftOrientedType + rightOrientedType) % orientedTypes;
    if (orientedType !== 0) {
      const unorientedType = orientedType - 1;
      result[unorientedType].push(piece);
    }
  }
  return result;
}

function combine(algTraceWithCost: AlgTraceWithCost, twistWithCost: TwistWithCost): AlgTraceWithCost {
  return {
    targetUnorientedByType: combineUnorientedByTypes(algTraceWithCost.targetUnorientedByType, twistWithCost.twist.unorientedByType),
    algTrace: algTraceWithCost.algTrace.withSuffix(twistWithCost.twist),
    cost: algTraceWithCost.cost + twistWithCost.cost,
  };
}

export function createTwistSolver(pieceDescription: PieceDescription, twistsWithCosts: TwistWithCost[]): TwistSolver {
  assert(pieceDescription.unorientedTypes <= 2);
  const numItems = pieceDescription.orientedTypes ** pieceDescription.pieces.length;
  const algsByIndex: Optional<AlgTrace>[] = new Array(numItems).map(() => none);
  const costByIndex: number[] = new Array(numItems).map(() => Infinity);
  const targetUnorientedByType: Piece[][] = new Array(pieceDescription.unorientedTypes).map(() => []);
  const unprocessed: AlgTraceWithCost[] = [{targetUnorientedByType, algTrace: emptyAlgTrace(), cost: 0}];
  while (unprocessed.length > 0) {
    const current = extractMin(unprocessed);
    const index = unorientedByTypeIndex(current.targetUnorientedByType);
    const previousCost = costByIndex[index];
    if (current.cost < previousCost) {
      algsByIndex[index] = some(current.algTrace);
      for (let twistWithCost of twistsWithCosts) {
        unprocessed.push(combine(current, twistWithCost));
      }
    }
  }
  return new TwistSolverImpl(algsByIndex);
}
