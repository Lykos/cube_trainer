import { BigScrambleGroup } from './big-scramble-group';
import { Piece } from './piece';
import { PieceDescription } from './piece-description';
import { subsets, sum } from '../utils';
import { factorial } from './combinatorics-utils';
import { assert } from '../assert';

function sortedCycleLengthPossibilities(remainingPieces: number, allowOddPermutations: boolean): number[][] {
  return sortedCycleLengthPossibilitiesWithPrefix(remainingPieces, allowOddPermutations, []);
}

function minHasSmallerPieceIndex(pieces: Piece[], piece: Piece) {
  return pieces.some(p => p.pieceId < piece.pieceId);
}

function sortedCycleLengthPossibilitiesWithPrefix(remainingPieces: number, allowOddPermutations: boolean, prefix: number[]): number[][] {
  if (remainingPieces === 0) {
    // That's valid. Nothing left to permute, so the prefix is all there is.
    return [prefix];
  } else if (remainingPieces === 1 || remainingPieces === 2 && !allowOddPermutations) {
    // Parity. So it's impossible, so 0 possibilities.
    return [];
  }
  // Each cycle has to be at least as long as the previous one.
  const minLength = prefix.length > 0 ? prefix[-1] : 2;
  let possibilities: number[][] = [];
  for (let i = minLength; i <= remainingPieces; ++i) {
    possibilities = possibilities.concat(sortedCycleLengthPossibilitiesWithPrefix(remainingPieces - i, allowOddPermutations, prefix.concat([i])));
  }
  return possibilities;
}

export class PiecePermutationDescription {
  constructor(readonly pieceDescription: PieceDescription,
              readonly allowOddPermutations: boolean) {
    assert(this.unorientedTypes <= 2, 'unsupported number of unoriented types');
  }

  get pieces() {
    return this.pieceDescription.pieces;
  }

  get unorientedTypes() {
    return this.pieceDescription.unorientedTypes;
  }

  get count() {
    const divisor = this.allowOddPermutations ? 1 : 2;
    // Every piece except the last has a choice for the orientation.
    const orientations = (this.unorientedTypes + 1) ** (this.pieces.length - 1);
    const permutations = factorial(this.pieceDescription.pieces.length);
    return orientations * permutations / divisor;
  }

  groups(): BigScrambleGroup[] {
    return subsets(this.pieces).flatMap(solved => this.groupsWithSolvedAndUnoriented(solved, []));
  }

  private groupsWithSolvedAndUnoriented(solved: Piece[], unoriented: Piece[][]): BigScrambleGroup[] {
    assert(unoriented.length <= this.unorientedTypes, 'unoriented.length <= this.unorientedTypes');
    const remainingPieces = this.pieces.filter(p => !solved.includes(p) && !unoriented.some(unorientedForType => minHasSmallerPieceIndex(unorientedForType, p)));
    if (unoriented.length === this.unorientedTypes) {
      const unorientationSum = sum(unoriented.map((unorientedForType, unorientedType) => unorientedForType.length * (unorientedType + 1))) % (unoriented.length + 1);
      if (remainingPieces.length === 0 && unorientationSum !== 0) {
        // Invalid twist. So it's impossible, so 0 possibilities. If we have remaining unsolved, the twist can be in that part.
        return [];
      }
      sortedCycleLengthPossibilities(remainingPieces.length, this.allowOddPermutations).map(
        cycleLengths => [new BigScrambleGroup(this, solved, unoriented, remainingPieces, cycleLengths)]
      );
    }
    return subsets(remainingPieces).flatMap(
      unorientedForType => this.groupsWithSolvedAndUnoriented(solved, unoriented.concat([unorientedForType]))
    );
  }
}
