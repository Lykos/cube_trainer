import { PiecePermutationDescription } from './piece-permutation-description';
import { sum } from '../utils';
import { Piece } from './piece';
import { assert } from '../assert';
import { ncr } from './combinatorics-utils';

// Represents one big group of similar scrambles, i.e.
// * same number of pieces solved
// * same number of pieces twisted or flipped
// * same number of pieces permuted
// * same cycle sizes.
export class BigScrambleGroup {
  constructor(
    readonly description: PiecePermutationDescription,
    // Solved pieces.
    readonly solved: Piece[],
    // Only used for corners, edges and midges.
    // It's an array because there can be multiple types of unoriented.
    // (clockwise and counter-clockwise for corners)
    readonly unorientedByType: Piece[][],
    // Permuted pieces
    readonly permuted: Piece[],
    readonly sortedCycleLengths: number[]) {
    assert(description.pieces.length === this.solved.length + sum(this.unorientedByType.map(e => e.length)) + this.permuted.length, 'inconsistent number of pieces');
    assert(sum(sortedCycleLengths) ===  this.permuted.length, 'inconsistent number of pieces and cycle lengths');
  }

  get unorientedTypes() {
    return this.unorientedByType.length;
  }

  get pieces() {
    return this.description.pieces;
  }

  get count() {
    // TODO
    return 1;
  }

  // Number of permutations in this group.
  get probability() {
    const solvedChoices = ncr(this.pieces.length, this.solved.length);
    let remainingPieces = this.pieces.length - this.solved.length;
    let unorientedChoices = 1;
    this.unorientedByType.forEach(unorientedForType => {
      unorientedChoices *= ncr(remainingPieces, unorientedForType.length);
      remainingPieces -= unorientedForType.length;
    });
    // TODO: Cycle lengths
    return solvedChoices * unorientedChoices / this.description.count;
  }
}
