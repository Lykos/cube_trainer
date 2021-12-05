import { Piece } from './piece';
import { assert } from '../assert';

// Returns an array of integers from `0` to `n`.
// e.g. `range(5) === [0, 1, 2, 3, 4, 5]`
function range(n: number): number[] {
  assert(n >= 0, 'n in range(n) has to be non-negative');
  return [...Array(n + 1).keys()];
}

export class PieceDescription {
  readonly pieces: Piece[];
  constructor(readonly numPieces: number,
              readonly unorientedTypes: number) {
    assert(numPieces >= 2, 'There have to be at least 2 pieces');
    assert(unorientedTypes >= 0, 'The number of oriented types has to be non-negative');
    this.pieces = range(numPieces - 1).map(pieceId => { return {pieceId}; });
  }
}

export const CORNER = new PieceDescription(8, 2);
export const EDGE = new PieceDescription(12, 1);
