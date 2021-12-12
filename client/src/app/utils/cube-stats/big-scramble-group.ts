import { PiecePermutationDescription } from './piece-permutation-description';
import { sum } from '../utils';
import { Piece } from './piece';
import { assert } from '../assert';
import { ncr, factorial } from './combinatorics-utils';

// Represents one big group of similar scrambles, i.e.
// * same number of pieces solved, twisted or flipped
// * same number of pieces permuted
// * same cycle sizes.
export class BigScrambleGroup {
  constructor(
    readonly description: PiecePermutationDescription,
    // Solved or unoriented pieces.
    readonly solvedOrUnoriented: Piece[],
    // Permuted pieces
    readonly permuted: Piece[],
    readonly sortedCycleLengths: number[]) {
    assert(description.pieces.length === this.solvedOrUnoriented.length + this.permuted.length, `inconsistent number of pieces (${description.pieces.length} vs ${this.solvedOrUnoriented.length} + ${this.permuted.length})`);
    assert(sum(sortedCycleLengths) ===  this.permuted.length, 'inconsistent number of pieces and cycle lengths');
  }

  get numOrientedTypes() {
    return this.description.numOrientedTypes;
  }

  get pieces() {
    return this.description.pieces;
  }

  // Number of permutations in this group.
  get count() {
    let remainingPieces = this.permuted.length;
    let permutedChoices = 1;
    let lastCycleLength = 0;
    let numCyclesWithLastLength = 0;
    // We have to divide by this to account for the fact that we don't
    // care about the order in case of multiple cycles of the same length.
    let cyclePermutationDivisor = 1;
    // For all except for the last permuted piece, we can choose the orientation.
    // Note that in case of no permuted pieces, we took care of excluding invalid
    // possibilities earlier.
    const orientationChoices = this.numOrientedTypes ** (this.pieces.length - 1)
    this.sortedCycleLengths.forEach(cycleLength => {
      // Choices for the pieces in this cycle plus orders within the cycle.
      permutedChoices *= ncr(remainingPieces, cycleLength) * factorial(cycleLength - 1);
      remainingPieces -= cycleLength;
      if (cycleLength === lastCycleLength) {
        ++numCyclesWithLastLength;
      } else {
        cyclePermutationDivisor *= factorial(numCyclesWithLastLength); 
        lastCycleLength = cycleLength;
        numCyclesWithLastLength = 1;
      }
    });
    cyclePermutationDivisor *= factorial(numCyclesWithLastLength);
    return permutedChoices * orientationChoices / cyclePermutationDivisor;
  }
}
