import { Piece } from './piece';
import { PiecePermutationDescription } from './piece-permutation-description';

function swap<X>(xs: X[], i: number, j: number) {
  const x = xs[i];
  xs[i] = xs[j];
  xs[j] = x;
}

function rand(n: number) {
  return Math.floor(Math.random() * n);
}

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

export class Scramble {
  constructor(readonly pieces: Piece[], readonly orientedTypesByPosition: number[], readonly orientedTypes: number) {}

  get unorientedTypes() {
    return this.orientedTypes - 1;
  }
}

export function randomScramble(piecePermutationDescription: PiecePermutationDescription): Scramble {
  const pieces = [...piecePermutationDescription.pieces];
  const orientedTypes = [...pieces].map(() => rand(piecePermutationDescription.orientedTypes));
  shuffle(pieces, piecePermutationDescription.allowOddPermutations);
  return new Scramble(pieces, orientedTypes, piecePermutationDescription.orientedTypes);
}
