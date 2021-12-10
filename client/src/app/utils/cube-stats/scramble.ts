import { Piece } from './piece';
import { PiecePermutationDescription } from './piece-permutation-description';
import { rand, swap } from '../utils';
import { Solvable } from './solvable';
import { OrientedType, solvedOrientedType } from './oriented-type';
import { assert } from '../assert';
import { Probabilistic, deterministic } from './probabilistic';
import { Parity, EvenCycle, ThreeCycle, ParityTwist, DoubleSwap } from './alg';

function shuffle<X>(xs: X[], allowOddPermutations: boolean) {
  let isEven = true;
  const n = xs.length;
  for (let i = 0; i < n; ++i) {
    const j = i + rand(n - i);
    if (j != i) {
      swap(xs, i, j);
      isEven = !isEven;
    }
  }
  if (!isEven && !allowOddPermutations) {
    swap(xs, 0, 1);
  }
}

export class Scramble implements Solvable<Scramble> {
  constructor(readonly pieces: Piece[], readonly orientedTypesByPosition: number[], readonly orientedTypes: number) {}

  get unorientedTypes() {
    return this.orientedTypes - 1;
  }

  applyCycleBreakFromSwap(cycleBreak: ThreeCycle): Scramble {
    // TODO
    assert(false); return this;
  }

  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): Scramble {
    // TODO
    assert(false); return this;
  }

  applyParity(parity: Parity): Scramble {
    // TODO
    assert(false); return this;
  }

  applyParityTwist(parity: ParityTwist): Scramble {
    // TODO
    assert(false); return this;
  }

  applyPartialDoubleSwap(doubleSwap: DoubleSwap): Scramble {
    // TODO
    assert(false); return this;
  }

  applyCompleteDoubleSwap(doubleSwap: DoubleSwap): Scramble {
    // TODO
    assert(false); return this;
  }

  applyCompleteEvenCycle(doubleSwap: EvenCycle): Scramble {
    // TODO
    assert(false); return this;
  }

  applyPartialEvenCycle(doubleSwap: EvenCycle): Scramble {
    // TODO
    assert(false); return this;
  }

  decideIsParityTime(): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false); return deterministic([this, false]);
  }

  decideIsSolved(piece: Piece): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false); return deterministic([this, false]);
  }

  decideIsPermuted(piece: Piece): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false); return deterministic([this, false]);
  }

  decideHasPermuted(): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false); return deterministic([this, false]);
  }

  decideOrientedTypeForPiece(piece: Piece): Probabilistic<[Scramble, OrientedType]> {
    // TODO
    assert(false); return deterministic([this, solvedOrientedType]);
  }

  decideUnorientedByType(): Probabilistic<[Scramble, readonly (readonly Piece[])[]]> {
    // TODO
    assert(false); return deterministic([this, []]);
  }

  decideCycleLength(piece: Piece): Probabilistic<[Scramble, number]> {
    // TODO
    assert(false); return deterministic([this, 0]);
  }

  decideNextPiece(piece: Piece): Probabilistic<[Scramble, Piece]> {
    // TODO
    assert(false); return deterministic([this, {pieceId: 0}]);
  }
}

export function randomScramble(piecePermutationDescription: PiecePermutationDescription): Scramble {
  const pieces = [...piecePermutationDescription.pieces];
  const orientedTypes = [...pieces].map(() => rand(piecePermutationDescription.orientedTypes));
  shuffle(pieces, piecePermutationDescription.allowOddPermutations);
  return new Scramble(pieces, orientedTypes, piecePermutationDescription.orientedTypes);
}
