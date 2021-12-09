import { Piece } from './piece';
import { PiecePermutationDescription } from './piece-permutation-description';
import { rand, swap } from '../utils';
import { Solvable } from './solvable';

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
    assert(false);
  }

  applyCycleBreakFromUnpermuted(cycleBreak: ThreeCycle): Scramble {
    // TODO
    assert(false);
  }

  applyParity(parity: Parity): Scramble {
    // TODO
    assert(false);
  }

  applyParityTwist(parity: ParityTwist): Scramble {
    // TODO
    assert(false);
  }

  applyPartialDoubleSwap(doubleSwap: DoubleSwap): Scramble {
    // TODO
    assert(false);
  }

  applyCompleteDoubleSwap(doubleSwap: DoubleSwap): Scramble {
    // TODO
    assert(false);
  }

  applyCompleteEvenCycle(doubleSwap: EvenCycle): Scramble {
    // TODO
    assert(false);
  }

  applyPartialEvenCycle(doubleSwap: EvenCycle): Scramble {
    // TODO
    assert(false);
  }

  decideIsParityTime(): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false);
  }

  decideIsSolved(piece: Piece): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false);
  }

  decideIsPermuted(piece: Piece): Probabilistic<[Scramble, boolean]> {
    // TODO
    assert(false);
  }

  decideOrientedTypeForPieces(piece: readonly Piece[]): Probabilistic<[Scramble, PartiallyFixedOrientedType]> {
    // TODO
    assert(false);
  }

  decideCycleLength(piece: Piece): Probabilistic<[Scramble, number]> {
    // TODO
    assert(false);
  }

  decideNextPiece(piece: Piece): Probabilistic<[Scramble, Piece]> {
    // TODO
    assert(false);
  }
}

export function randomScramble(piecePermutationDescription: PiecePermutationDescription): Scramble {
  const pieces = [...piecePermutationDescription.pieces];
  const orientedTypes = [...pieces].map(() => rand(piecePermutationDescription.orientedTypes));
  shuffle(pieces, piecePermutationDescription.allowOddPermutations);
  return new Scramble(pieces, orientedTypes, piecePermutationDescription.orientedTypes);
}
