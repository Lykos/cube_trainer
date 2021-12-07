import { Piece } from './piece';
import { Alg, ParityTwist, Parity, EvenCycle, DoubleSwap, Twist } from './alg';
import { AlgCounts, AlgCountsBuilder } from './alg-counts';
import { assert } from '../assert';
import { Optional, some, none, mapOptional, orElse, forceValue } from '../optional';

function splitPiecesIntoAlgs(buffer: Piece, pieces: Piece[], maxCycleLengthForBuffer: (piece: Piece) => number) {
  const maxCycleLength = maxCycleLengthForBuffer(buffer);
  assert(maxCycleLength > 0);
  assert(maxCycleLength % 2 === 1);
  assert(pieces.length % 2 === 0);
  const algs: Alg[] = [];
  let lastPieces: Piece[] = []
  pieces.forEach(piece => {
    lastPieces.push(piece);
    if (lastPieces.length + 1 === maxCycleLength) {
      algs.push(new EvenCycle(buffer, lastPieces));
      lastPieces = [];
    }
  });
  algs.push(new EvenCycle(buffer, lastPieces));
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
    let currentCycle: Piece[] = [];
    this.algs.forEach(alg => {
      if (alg instanceof EvenCycle && sameOrNone(alg.firstPiece, currentBuffer)) {
        currentBuffer = some(alg.firstPiece);
        currentCycle = currentCycle.concat(alg.unorderedLastPieces);
      } else {
        if (currentCycle.length > 0) {
          processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(forceValue(currentBuffer), currentCycle, maxCycleLengthForBuffer));
          currentBuffer = none;
          currentCycle = [];
        }
        processedAlgs.push(alg)
      }
    });
    if (currentCycle.length > 0) {
      processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(forceValue(currentBuffer), currentCycle, maxCycleLengthForBuffer));
    }
    return new AlgTrace(processedAlgs);
  }

  countAlgs(): AlgCounts {
    const builder = new AlgCountsBuilder();
    this.algs.forEach(alg => {
      if (alg instanceof EvenCycle) {
        builder.incrementCycles();
      } else if (alg instanceof Parity) {
        builder.incrementCycles();
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
