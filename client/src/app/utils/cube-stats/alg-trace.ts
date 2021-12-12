import { Piece } from './piece';
import { Alg, ParityTwist, Parity, EvenCycle, DoubleSwap, Twist } from './alg';
import { AlgCounts, AlgCountsBuilder } from './alg-counts';
import { assert } from '../assert';
import { Optional, some, none, mapOptional, orElse, forceValue } from '../optional';

function splitPiecesIntoAlgs(buffer: Piece, numRemainingPieces: number, maxCycleLengthForBuffer: (piece: Piece) => number) {
  const maxCycleLength = maxCycleLengthForBuffer(buffer);
  assert(maxCycleLength > 0);
  assert(maxCycleLength % 2 === 1);
  assert(numRemainingPieces % 2 === 0);
  const algs: Alg[] = [];
  for (; numRemainingPieces >= maxCycleLength; numRemainingPieces -= maxCycleLength - 1) {
    algs.push(new EvenCycle(buffer, maxCycleLength - 1));
  }
  algs.push(new EvenCycle(buffer, numRemainingPieces));
  return algs;
}

function sameOrNone<X>(value: X, optional: Optional<X>): boolean {
  return orElse(mapOptional(optional, v => v === value), true);
}

export class AlgTrace {
  constructor(readonly algs: Alg[]) {}

  withPrefix(alg: Alg) {
    return new AlgTrace([alg].concat(this.algs));
  }

  withSuffix(alg: Alg) {
    return new AlgTrace(this.algs.concat([alg]));
  }

  withMaxCycleLength(maxCycleLengthForBuffer: (piece: Piece) => number) {
    let processedAlgs: Alg[] = [];
    let currentBuffer: Optional<Piece> = none;
    let numRemainingPieces = 0;
    this.algs.forEach(alg => {
      if (alg instanceof EvenCycle && sameOrNone(alg.firstPiece, currentBuffer)) {
        currentBuffer = some(alg.firstPiece);
        numRemainingPieces += alg.numRemainingPieces;
      } else {
        if (numRemainingPieces > 0) {
          processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(forceValue(currentBuffer), numRemainingPieces, maxCycleLengthForBuffer));
          currentBuffer = none;
          numRemainingPieces = 0;
        }
        if (alg instanceof EvenCycle) {
          currentBuffer = some(alg.firstPiece);
          numRemainingPieces = alg.numRemainingPieces;
        } else {
          processedAlgs.push(alg)
        }
      }
    });
    if (numRemainingPieces > 0) {
      processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(forceValue(currentBuffer), numRemainingPieces, maxCycleLengthForBuffer));
    }
    return new AlgTrace(processedAlgs);
  }

  countAlgs(): AlgCounts {
    const builder = new AlgCountsBuilder();
    this.algs.forEach(alg => {
      if (alg instanceof EvenCycle) {
        builder.incrementCycles(alg.length);
      } else if (alg instanceof Parity) {
        builder.incrementParities();
      } else if (alg instanceof ParityTwist) {
        builder.incrementParityTwists();
      } else if (alg instanceof DoubleSwap) {
        builder.incrementDoubleSwaps();
      } else if (alg instanceof Twist) {
        builder.incrementTwists(alg.numUnoriented);
      } else {
        assert(false, 'unknown alg type');
      }
    });
    return builder.build();
  }
}

export function emptyAlgTrace() {
  return new AlgTrace([]);
}
