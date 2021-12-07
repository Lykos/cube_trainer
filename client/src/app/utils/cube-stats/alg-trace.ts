import { Piece } from './piece';
import { Alg, ParityTwist, Parity, EvenCycle, DoubleSwap } from './alg';
import { AlgCounts, AlgCountsBuilder } from './alg-counts';
import { assert } from '../assert';

function splitPiecesIntoAlgs(pieces: Piece[], maxPiecesPerAlg: number) {
  assert(maxPiecesPerAlg > 0);
  assert(maxPiecesPerAlg % 2 === 1);
  const algs: Alg[] = [];
  let lastPieces: Piece[] = []
  pieces.forEach(piece => {
    lastPieces.push(piece);
    if (lastPieces.length === maxPiecesPerAlg) {
      algs.push(new EvenCycle(lastPieces));
      lastPieces = [];
    }
  });
  algs.push(new EvenCycle(lastPieces));
  return algs;
}

export class AlgTrace {
  constructor(readonly algs: Alg[]) {}

  withPrefix(alg: Alg) {
    return new AlgTrace([alg].concat(this.algs));
  }
  
  withSuffix(alg: Alg) {
    return new AlgTrace(this.algs.concat([alg]));
  }

  withMaxCycleLength(n: number) {
    assert(n > 0);
    assert(n % 2 === 1);
    // TODO
    let processedAlgs: Alg[] = [];
    let currentCycle: Piece[] = [];
    this.algs.forEach(alg => {
      if (alg instanceof EvenCycle) {
        currentCycle = currentCycle.concat(alg.pieces);
      } else {
        if (currentCycle.length > 0) {
          processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(currentCycle, n));
          currentCycle = [];
        }
        processedAlgs.push(alg)
      }
    });
    processedAlgs = processedAlgs.concat(splitPiecesIntoAlgs(currentCycle, n));
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
